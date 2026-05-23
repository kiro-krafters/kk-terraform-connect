module "lex_bot" {
  for_each               = local.lex_bots_with_lambda_arn
  source                 = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lexbot-wrapper?ref=v1.0.13"
  create_lexbot          = true
  prefix_region          = local.region_prefix
  prefix_company         = var.company_prefix
  application            = var.application
  env                    = var.env
  name                   = "${each.key}-${local.region_prefix}-${var.env}"
  auto_build_bot_locales = true
  role_arn               = try(module.lex_bot_role[each.key].iam_role_arn, "")
  data_privacy = {
    child_directed = false
  }
  idle_session_ttl_in_seconds = 86400
  bot_file_s3_location = {
    s3_bucket     = module.aws_lex_s3_bucket.bucket_id
    s3_object_key = "bot-definition/${each.value.lex_json_file}_${local.lex_bot_hashes[each.value.lex_json_file]}.zip"
  }
  # description           = "Lex Bots for ${var.env} in ${local.region_prefix}"
  locale_specification = { for lang in local.lex_bots_with_lambda_arn[each.key].languages : lang => { source_bot_version = "DRAFT" } }
  create_lexbot_version = true
  create_lexbot_alias   = true
  bot_alias_name        = "live"
  sentiment_analysis_settings = {
    detect_sentiment = false
  }
  bot_alias_locale_settings = [
    for lang in each.value.languages : {
      locale_id = lang
      bot_alias_locale_setting = {
        enabled = true
        code_hook_specification = (each.value.lambda_arn != null && each.value.lambda_arn != "") ? {
          lambda_code_hook = {
            code_hook_interface_version = "1.0"
            lambda_arn                  = each.value.lambda_arn
          }
        } : null
      }
    }
  ]
  bot_tags            = local.tags
  version_description = "Bot version for ${each.value.lex_json_file} - hash: ${filesha256("./bot_files/${each.value.lex_json_file}")}"
  depends_on          = [module.aws_lex_s3_bucket_objects, module.lex_bot_role]
}
module "lex_attachment" {
  for_each = local.lex_bots_with_lambda_arn

  source = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lexbot-wrapper?ref=v1.0.13"

  prefix_region   = local.region_prefix
  prefix_company  = var.company_prefix
  application     = var.application
  env             = var.env
  lex_association = true

  bot_alias_arn = module.lex_bot[each.key].bot_alias_arn
  instance_id   = "arn:aws:connect:${var.region}:${var.account_number}:instance/${module.amazon_connect.instance_id}"
  depends_on = [
    module.lex_bot
  ]
}

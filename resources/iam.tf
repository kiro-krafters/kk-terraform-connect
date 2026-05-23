module "cases_firehose_extra_policy" {
  source      = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-policy?ref=v1.0.0"
  name        = format("%s-iam-policy-cases-extra-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description = "Extra policy for Cases Firehose: S3 + CloudWatch logs"
  policy      = data.aws_iam_policy_document.cases_firehose_combined.json
  count       = 1
}

module "cases_firehose_lambda_policy" {
  source      = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-policy?ref=v1.0.0"
  name        = format("%s-iam-policy-cases-lambda-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description = "Policy for Cases Firehose to invoke Lambda"
  policy      = data.aws_iam_policy_document.firehose_lambda_invoke_policy.json
  count       = 1
}

module "cases_firehose_role" {
  source                          = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-assumable-role?ref=v1.0.0"
  role_name                       = format("KinesisFirehoseServiceRole-%s-cases-delivery-%s-%s", var.company_prefix, local.region_prefix, var.env)
  role_description                = "IAM role for Cases Firehose delivery stream"
  create_role                     = true
  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.firehose_trust_policy.json
  custom_role_policy_arns = [
    module.cases_firehose_extra_policy[0].arn,
    module.cases_firehose_lambda_policy[0].arn
  ]
  role_path             = "/"
  force_detach_policies = false
  tags                  = local.tags
  depends_on            = [module.cases_firehose_extra_policy, module.cases_firehose_lambda_policy]
}

module "ctr_firehose_policy" {
  source      = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-policy?ref=v1.0.0"
  name        = format("%s-iam-policy-ctr-firehose-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description = "Combined required policy for CTR Firehose role"
  policy      = data.aws_iam_policy_document.ctr_firehose_combined.json
  count       = 1
}

module "ctr_firehose_role" {
  source                          = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-assumable-role?ref=v1.0.0"
  role_name                       = format("KinesisFirehoseServiceRole-%s-ctr-delivery-%s-%s", var.company_prefix, local.region_prefix, var.env)
  role_description                = "IAM role for CTR Firehose delivery stream"
  create_role                     = true
  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.firehose_trust_policy.json
  custom_role_policy_arns = [
    module.ctr_firehose_policy[0].arn
  ]
  role_path             = "/"
  force_detach_policies = false
  tags                  = local.tags
  depends_on            = [module.ctr_firehose_policy]
}

module "lex_bot_role" {
  for_each                        = local.lex_bots_with_lambda_arn
  source                          = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam//modules/iam-assumable-role?ref=v1.0.0"
  create_role                     = true
  role_name_prefix                = format("%s-iam-role-%s-%s-%s", var.company_prefix, local.region_prefix, var.env, each.key)
  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.lex_role_policy.json
  custom_role_policy_arns = [
    "${module.lex_bot_alias_policy[each.key].arn}"
  ]
}

module "lex_bot_alias_policy" {
  for_each = local.lex_bots_with_lambda_arn
  source   = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam//modules/iam-policy?ref=v1.0.0"
  name     = format("%s-iam-policy-%s-%s-%s", var.company_prefix, each.key, local.region_prefix, var.env)
  policy   = data.aws_iam_policy_document.bot_alias_policy[each.key].json
}

module "lex_resource_policy" {
  for_each            = local.lex_bots_with_lambda_arn
  source              = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lexbot-wrapper?ref=v1.0.13"
  create_alias_policy = true
  prefix_company      = var.company_prefix
  prefix_region       = local.region_prefix
  application         = var.application
  env                 = var.env
  bot_alias_arn       = module.lex_bot[each.key].bot_alias_arn != "" ? module.lex_bot[each.key].bot_alias_arn : format("arn:aws:lex:%s:%s:bot-alias/%s/TSTALIASID", var.region, var.account_number, module.lex_bot[each.key].bot_id)
  lex_policy          = data.aws_iam_policy_document.lex_resource_policy[each.key].json
  depends_on          = [module.lex_bot]
}

module "cases_eventbridge_firehose_policy" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-policy?ref=v1.0.0"

  name        = format("%s-iam-policy-cases-to-firehose-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description = "Allows EventBridge to put events into Cases Firehose stream"

  policy = data.aws_iam_policy_document.cases_eventbridge_firehose_policy.json

  tags = local.tags
}

module "cases_eventbridge_role" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-assumable-role?ref=v1.0.0"

  role_name = format("%s-iam-role-cases-to-firehose-%s-%s", var.company_prefix, local.region_prefix, var.env)

  role_description = "IAM role assumed by EventBridge to deliver Cases events to Firehose"

  create_role                     = true
  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.cases_eventbridge_trust_policy.json

  custom_role_policy_arns = [
    module.cases_eventbridge_firehose_policy.arn
  ]

  role_path             = "/"
  force_detach_policies = false

  tags = local.tags

  depends_on = [
    module.cases_eventbridge_firehose_policy
  ]
}

module "glue_service_role" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-assumable-role?ref=v1.0.0"

  role_name = format("AWSGlueServiceRole-%s-glue-service-role-%s-%s", var.company_prefix, local.region_prefix, var.env)

  create_role                     = true
  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.glue_trust_policy.json

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonAthenaFullAccess",
    module.glue_service_custom_policy.arn
  ]

  tags = local.tags

  depends_on = [module.glue_service_custom_policy]
}

module "glue_service_custom_policy" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-policy?ref=v1.0.0"

  name        = format("%s-iam-policy-glue-service-custom-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description = "Custom policy for Glue service role to access S3 and CloudWatch"
  policy      = data.aws_iam_policy_document.glue_service_policy.json

  tags = local.tags
}

module "connect_backup_eventbridge_scheduler_policy" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-policy?ref=v1.0.0"

  name = format(
    "%s-iam-policy-connect-backup-scheduler-%s-%s",
    var.company_prefix,
    local.region_prefix,
    var.env
  )

  description = "Allows EventBridge Scheduler to invoke Connect backup Lambda"

  policy = data.aws_iam_policy_document.connect_backup_eventbridge_policy.json

  tags = local.tags
}

module "connect_backup_eventbridge_scheduler_role" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-assumable-role?ref=v1.0.0"

  role_name = format(
    "%s-iam-role-connect-backup-scheduler-%s-%s",
    var.company_prefix,
    local.region_prefix,
    var.env
  )

  role_description = "IAM role assumed by EventBridge Scheduler to invoke Connect backup Lambda function"

  create_role                     = true
  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.connect_backup_eventbridge_trust_policy.json

  custom_role_policy_arns = [
    module.connect_backup_eventbridge_scheduler_policy.arn
  ]

  role_path             = "/"
  force_detach_policies = false

  tags = local.tags

  depends_on = [
    module.connect_backup_eventbridge_scheduler_policy
  ]
}

module "vm_presigner_user_policy" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-policy?ref=v1.0.0"
  name   = format("%s-iam-policy-vm-presigner-%s-%s", var.company_prefix, local.region_prefix, var.env)
  policy = data.aws_iam_policy_document.vm_presigner_user_policy.json
}

module "vm_presigner_user" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-iam/modules/iam-user?ref=v1.0.0"

  name                  = format("%s-iam-vm-presigner-user-%s-%s", var.company_prefix, local.region_prefix, var.env)
  create_user           = true
  create_iam_access_key = true

  policy_arns = [
    module.vm_presigner_user_policy.arn
  ]

  tags = local.tags
}



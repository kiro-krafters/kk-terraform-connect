module "s3_cfn_bucket" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-cfn-stack-templates-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

module "s3_prompt_bucket" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-connect-prompts-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}



module "s3_cfn_objects" {
  source        = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper/s3_object?ref=v1.0.6"
  for_each      = local.s3_cfn_objects_map
  create_object = true
  bucket        = "${var.company_prefix}-s3-cfn-stack-templates-${local.region_prefix}-${var.env}"
  key           = each.value.key
  file_source   = each.value.file_source
  source_hash   = filesha256(each.value.file_source)
  depends_on    = [module.s3_cfn_bucket]
}

module "s3_prompt_objects" {
  source        = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper/s3_object?ref=v1.0.6"
  for_each      = local.s3_prompt_objects_map
  create_object = true
  bucket        = "${var.company_prefix}-s3-connect-prompts-${local.region_prefix}-${var.env}"
  key           = each.value.key
  file_source   = each.value.file_source
  source_hash   = filesha256(each.value.file_source)
  depends_on    = [module.s3_prompt_bucket]
}

# Recording S3 bucket configurations
module "s3_call_recording" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-call-recording-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }

  lifecycle_rules = local.s3_lifecycle_rules

  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

# Chat transcript S3 bucket configurations
module "s3_chat_transcript" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-chat-transcript-%s-%s", var.company_prefix, local.region_prefix, var.env)
  lambda_trigger           = true
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }
  notification_configuration = {
    lambda = {
      attach_flow_sms_with_case_object_created = {
        function_arn  = module.attach_flow_sms_with_case_lambda.lambda_function_arn
        function_name = module.attach_flow_sms_with_case_lambda.lambda_function_name
        events        = ["s3:ObjectCreated:*"]
        filter_prefix = "chat_transcripts/"
        filter_suffix = ".json"
      }
    }
  }

  lifecycle_rules       = local.s3_lifecycle_rules
  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

# Cases events S3 bucket configurations
module "s3_cases_events" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-cases-events-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }
  lifecycle_rules       = local.s3_lifecycle_rules
  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

module "aws_lex_s3_bucket" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-lex-bots-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm = "AES256"
        }
        bucket_key_enabled = true
      }
    ]
  }

  versioning_configuration = {
    status     = true
    mfa_delete = false
  }

  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

module "aws_lex_s3_bucket_objects" {
  for_each = { for k, v in local.lex_bots_with_lambda_arn : v.lex_json_file => "./bot_files/${v.lex_json_file}" }
  source   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper/s3_object?ref=v1.0.6"

  create_object = true
  content_type  = "application/zip"

  bucket      = module.aws_lex_s3_bucket.bucket_id
  key         = "bot-definition/${each.key}_${local.lex_bot_hashes[each.key]}.zip"
  file_source = each.value
  source_hash = filesha256(each.value)

  depends_on = [module.aws_lex_s3_bucket]
}

module "s3_glue_database_storage" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-glue-database-storage-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }

  lifecycle_rules       = local.s3_lifecycle_rules
  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

module "s3_connect_backup_bucket" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-connect-backup-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }

  lifecycle_rules       = local.s3_connect_backup_lifecycle_rules
  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

module "s3_athena_query_result_bucket" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-athena-query-result-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }

  lifecycle_rules       = local.s3_lifecycle_rules
  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

module "s3_sms_sender_bucket" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-sms-sender-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }

  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}
module "sms_sender_s3_policy" {
  source            = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  create_bucket     = false
  cloudfront_policy = true
  bucket_name       = format("%s-s3-sms-sender-%s-%s", var.company_prefix, local.region_prefix, var.env)
  policy            = data.aws_iam_policy_document.sms_sender_backend_bucket_policy.json
  depends_on        = [module.cloudfront]
}
module "s3_contact_trace_records" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-contact-trace-records-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }
  lifecycle_rules       = local.s3_lifecycle_rules
  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

# Voicemail recording S3 bucket configurations
module "s3_voicemail_recording" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.12"
  bucket_name              = local.voicemail_recording_bucket_name
  eventbridge              = true
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }

  lifecycle_rules       = local.s3_lifecycle_rules
  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}
# Voicemail transcription S3 bucket configurations
module "s3_voicemail_transcription" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.12"
  bucket_name              = local.voicemail_transcription_bucket_name
  eventbridge              = true
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }

  lifecycle_rules       = local.s3_lifecycle_rules
  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

module "s3_case_management_bucket" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-case-management-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = true, mfa_delete = false }
  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = module.common_aws_kms_key.key_arn
        }
        bucket_key_enabled = true
      }
    ]
  }
  metric_configuration  = [{ name = "EntireBucket" }]
  tags                  = local.tags
  logging_target_bucket = local.server_access_logs_bucket_name
}

module "case_management_s3_policy" {
  source            = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  create_bucket     = false
  cloudfront_policy = true
  bucket_name       = format("%s-s3-case-management-%s-%s", var.company_prefix, local.region_prefix, var.env)
  policy            = data.aws_iam_policy_document.case_management_backend_bucket_policy.json
  depends_on        = [module.case_management_cloudfront]
}

module "case_event_enrichment_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.case_event_enrichment
  handler                 = "cases_event_enrichment_lambda.lambda_handler"
  runtime                 = local.lambda_default_configurations.runtime
  local_existing_package  = "./lambda_function/cb-lmbd-case-event-enrichment.zip"
  layers                  = []
  timeout                 = local.lambda_default_configurations.timeout
  memory_size             = local.lambda_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["case_event_enrichment_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    DOMAIN_ID                   = var.cases_domain_id
    GENERAL_SUPPORT_TEMPLATE_ID = module.connect_cases_stack[0].outputs["oGeneralSupportTemplateId"]
    INSTANCE_ID                 = local.connect_instance_id
    LOG_LEVEL                   = "INFO"
    REFRESH                     = "1765445624"
    ACCOUNT_ID                  = data.aws_caller_identity.current.account_id
    REGION                      = var.region
  }
  tags = local.lambda_default_configurations.tags

  allowed_triggers = {
    Lex = {
      service    = "lexv2"
      source_arn = try("arn:aws:lex:${var.region}:${data.aws_caller_identity.current.account_id}:bot-alias/${values(module.lex_bot)[0].bot_id}/*", "")
    }
    Firehose = {
      service    = "firehose"
      source_arn = "arn:aws:firehose:${var.region}:${data.aws_caller_identity.current.account_id}:deliverystream/${format("%s-cases-event-stream-%s-%s", var.company_prefix, local.region_prefix, var.env)}"
    }
    Connect = {
      service    = "connect"
      source_arn = "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
    }
  }
}

module "intake_dialogue_function_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.intake_dialogue_function
  handler                 = "index.handler"
  runtime                 = local.lambda_node_default_configurations.runtime
  local_existing_package  = "./lambda_function/cb-lmbd-intake-dialogue-function.zip"
  layers                  = [module.intake_dialogue_function_lambda_layer.lambda_layer_arn]
  timeout                 = local.lambda_node_default_configurations.timeout
  memory_size             = local.lambda_node_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_node_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["intake_dialogue_function_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  #   environment_variables = {}
  tags = local.lambda_node_default_configurations.tags

  allowed_triggers = {
    Lex = {
      service    = "lexv2"
      source_arn = "arn:aws:lex:${var.region}:${data.aws_caller_identity.current.account_id}:bot-alias/${values(module.lex_bot)[0].bot_id}/*"
    }
    Connect = {
      service    = "connect"
      source_arn = "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
    }
  }
}


module "get_non_closed_cases_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.get_non_closed_cases
  handler                 = "index.handler"
  runtime                 = local.lambda_node_default_configurations.runtime
  local_existing_package  = "./lambda_function/cb-lmbd-get-non-closed-cases.zip"
  layers                  = [module.get_non_closed_cases_lambda_layer.lambda_layer_arn]
  timeout                 = local.lambda_node_default_configurations.timeout
  memory_size             = local.lambda_node_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_node_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["get_non_closed_cases_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    CASES_DOMAIN_ID = var.cases_domain_id
  }
  tags = local.lambda_node_default_configurations.tags

  allowed_triggers = {
    Connect = {
      service    = "connect"
      source_arn = "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
    }
  }
}

module "delete_all_cases_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.delete_all_cases
  handler                 = "index.handler"
  runtime                 = local.lambda_node_default_configurations.runtime
  local_existing_package  = "./lambda_function/cb-lmbd-delete-all-cases-v1.zip"
  layers                  = [module.delete_all_cases_lambda_layer.lambda_layer_arn]
  timeout                 = local.lambda_node_default_configurations.timeout
  memory_size             = local.lambda_node_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_node_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["delete_all_cases_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    CASES_DOMAIN_ID = var.cases_domain_id
  }
  tags = local.lambda_node_default_configurations.tags
}

module "connect_backup_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.connect_backup
  handler                 = "index.handler"
  runtime                 = local.lambda_node_default_configurations.runtime
  local_existing_package  = local.lambda_node_default_configurations.package
  layers                  = [module.connect_backup_lambda_layer.lambda_layer_arn]
  timeout                 = local.lambda_node_default_configurations.timeout
  memory_size             = local.lambda_node_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_node_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["connect_backup_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    CONNECT_INSTANCE_ID = local.connect_instance_id
    REGION              = var.region
    S3_BACKUP_BUCKET    = format("%s-s3-connect-backup-%s-%s", var.company_prefix, local.region_prefix, var.env)
  }
  tags = local.lambda_node_default_configurations.tags
}

module "sms_backend_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.sms_backend
  handler                 = "index.handler"
  runtime                 = local.lambda_node24_default_configurations.runtime
  local_existing_package  = local.lambda_node24_default_configurations.package
  layers                  = [module.sms_backend_lambda_layer.lambda_layer_arn]
  timeout                 = local.lambda_node24_default_configurations.timeout
  memory_size             = local.lambda_node24_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_node24_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["sms_backend_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    SMS_CONFIGURATION_SET               = "sms-referral-config"
    SMS_ORIGINATION_NUMBER              = var.sms_origination_number
    AWS_ACCOUNT_ID                      = data.aws_caller_identity.current.account_id
    CASES_DOMAIN_ID                     = var.cases_domain_id
    CUSTOMER_PROFILES_DOMAIN_NAME       = "cb-customer-profile-${var.env}"
    SMS_HISTORY_ID                      = module.connect_cases_stack[0].outputs["oSMSHistoryFieldID"]
    INBOUND_OUTBOUND_SMS_TRACKING_TABLE = module.connect_inbound_outbound_sms_tracking.dynamodb_table_id
    OUTBOUND_CUSTOMER_SMS_TABLE         = module.connect_outbound_customer_sms.dynamodb_table_id
    SMS_CONSENT_ID                      = module.connect_cases_stack[0].outputs["oFieldSMSConsentId"]
    CASE_VIEW_STATUS_TABLE              = module.case_view_status.dynamodb_table_id
  }
  tags = local.lambda_node24_default_configurations.tags
}

module "ctr_processor_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.ctr_processor
  handler                 = local.lambda_node24_default_configurations.handler
  runtime                 = local.lambda_node24_default_configurations.runtime
  local_existing_package  = local.lambda_node24_default_configurations.package
  timeout                 = local.lambda_node24_default_configurations.timeout
  memory_size             = local.lambda_node24_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_node24_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["ctr_processor_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  tags                    = local.lambda_node24_default_configurations.tags

  allowed_triggers = {
    Firehose = {
      service    = "firehose"
      source_arn = "arn:aws:firehose:${var.region}:${data.aws_caller_identity.current.account_id}:deliverystream/${format("%s-firehose-contact-trace-records-%s-%s", var.company_prefix, local.region_prefix, var.env)}"
    }
  }
}

module "inbound_sms_tracking" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.inbound_sms_tracking
  handler                 = "index.handler"
  runtime                 = local.lambda_node24_default_configurations.runtime
  local_existing_package  = local.lambda_node24_default_configurations.package
  layers                  = [module.inbound_sms_tracking_layer.lambda_layer_arn]
  timeout                 = local.lambda_node24_default_configurations.timeout
  memory_size             = local.lambda_node24_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_node24_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["inbound_sms_tracking_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    SMS_HISTORY_ID                      = module.connect_cases_stack[0].outputs["oSMSHistoryFieldID"]
    CASES_DOMAIN_ID                     = var.cases_domain_id
    OUTBOUND_CUSTOMER_SMS_TABLE         = module.connect_outbound_customer_sms.dynamodb_table_id
    INBOUND_OUTBOUND_SMS_TRACKING_TABLE = module.connect_inbound_outbound_sms_tracking.dynamodb_table_id
  }
  tags = local.lambda_node24_default_configurations.tags
}

module "vm_recording_processor_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.recording_processor
  handler                 = "vmx3_recording_processor.lambda_handler"
  runtime                 = "python3.13"
  local_existing_package  = local.lambda_default_configurations.package
  layers                  = [module.vm_recording_processor_lambda_layer.lambda_layer_arn]
  timeout                 = local.lambda_default_configurations.timeout
  memory_size             = local.lambda_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["vm_recording_processor_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    package_version        = "2025.09.13"
    aws_region             = var.region
    vmx3_recordings_bucket = module.s3_voicemail_recording.bucket_id
  }
  tags = local.tags

  allowed_triggers = {
    Kinesis = {
      service    = "kinesis"
      source_arn = module.kinesis.kinesis_stream_arn
    }
  }

  event_source_mapping = {
    kinesis = {
      event_source_arn  = module.kinesis.kinesis_stream_arn
      starting_position = "LATEST"
      batch_size        = 1
      filter_criteria = [
        {
          pattern = jsonencode({
            data = {
              Attributes = {
                vmx3_flag = ["1"]
              }
              Recordings = {
                ParticipantType = ["IVR"]
              }
              Agent = [null]
            }
          })
        }
      ]
    }
  }
}

module "vm_transcriber_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.transcriber
  handler                 = "vmx3_transcriber.lambda_handler"
  runtime                 = "python3.13"
  local_existing_package  = local.lambda_default_configurations.package
  timeout                 = local.lambda_default_configurations.timeout
  memory_size             = local.lambda_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["vm_transcriber_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    package_version       = "2025.09.13"
    aws_region            = var.region
    s3_transcripts_bucket = module.s3_voicemail_transcription.bucket_id
  }
  tags = local.tags

  allowed_triggers = {
    events = {
      service    = "events"
      source_arn = local.event_bridge_rule_arns.transcriber
    }
  }

}

module "vm_transcribe_error_handler_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.transcribe_error_handler
  handler                 = "vmx3_transcription_error_handler.lambda_handler"
  runtime                 = "python3.13"
  local_existing_package  = local.lambda_default_configurations.package
  timeout                 = local.lambda_default_configurations.timeout
  memory_size             = local.lambda_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["vm_transcribe_error_handler_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    package_version       = "2025.09.13"
    aws_region            = var.region
    s3_transcripts_bucket = module.s3_voicemail_transcription.bucket_id
  }
  tags = local.tags

  allowed_triggers = {
    EventBridge = {
      service    = "events"
      source_arn = local.event_bridge_rule_arns.transcribe_error
    }
  }
}

module "vm_packager_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.vm_packager
  handler                 = "vmx3_packager.lambda_handler"
  runtime                 = "python3.13"
  local_existing_package  = local.lambda_default_configurations.package
  layers                  = [module.vm_packager_lambda_layer.lambda_layer_arn]
  timeout                 = local.lambda_default_configurations.timeout
  memory_size             = local.lambda_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["vm_packager_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    package_version              = "2025.09.13"
    aws_region                   = var.region
    s3_recordings_bucket         = module.s3_voicemail_recording.bucket_id
    s3_transcripts_bucket        = module.s3_voicemail_transcription.bucket_id
    CASE_DOMAIN_ID               = var.cases_domain_id
    presigner_function_arn       = local.lambda_names.presigner
    inference_region             = var.region
    inference_model              = "us.amazon.nova-lite-v1:0"
    vmx3_do_genai_summary        = "false"
    default_vmx_mode             = "task"
    agent_email_key              = "Email"
    TZ                           = "America/New_York"
    default_email_from           = "AWS::NoValue"
    default_email_target         = "AWS::NoValue"
    default_queue_email_template = "AWS::NoValue"
    default_agent_email_template = "AWS::NoValue"
    default_guided_task_flow     = "N/A"
    default_task_flow            = "N/A"
    CASE_TEMPLATE_ID             = "N/A"
  }
  allowed_triggers = {
    events = {
      service    = "events"
      source_arn = local.event_bridge_rule_arns.vm_packager
    }
  }
  tags = local.tags
}

module "vm_voicemail_timestamper_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.vm_voicemail_timestamper
  handler                 = "vmx3_voicemail_timestamper.lambda_handler"
  runtime                 = "python3.13"
  local_existing_package  = local.lambda_default_configurations.package
  timeout                 = local.lambda_default_configurations.timeout
  memory_size             = local.lambda_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["vm_voicemail_timestamper_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations

  allowed_triggers = {
    Connect = {
      service    = "connect"
      source_arn = "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
    }
  }

  tags = local.tags
}

module "vm_presigner_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.presigner
  handler                 = "vmx3_presigner.lambda_handler"
  runtime                 = "python3.13"
  local_existing_package  = local.lambda_default_configurations.package
  timeout                 = local.lambda_default_configurations.timeout
  memory_size             = local.lambda_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["vm_presigner_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    email_url_expire = "1"
    package_version  = "2025.09.13"
    aws_region       = var.region
    secrets_key_id   = module.vm_access_secrets.secret_arn[0]
    tasks_url_expire = "3"
  }

  tags = local.tags
}

module "case_management_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.case_management
  handler                 = "dist/index.handler"
  runtime                 = "nodejs22.x"
  local_existing_package  = local.lambda_node_default_configurations.package
  layers                  = [module.case_management_lambda_layer.lambda_layer_arn]
  timeout                 = local.lambda_node_default_configurations.timeout
  memory_size             = local.lambda_node_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_node_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["case_management_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    AWS_ACCOUNT_ID           = data.aws_caller_identity.current.account_id
    CUSTOMER_PROFILES_DOMAIN = "cb-customer-profile-${var.env}"
    DOMAIN_ID                = var.cases_domain_id
    INSTANCE_ID              = local.connect_instance_id
    LOG_LEVEL                = "info"
    TABLE_NAME               = module.case_view_status.dynamodb_table_id
    TEMPLATE_ID              = module.connect_cases_stack[0].outputs["oGeneralSupportTemplateId"]
    CONNECT_DOMAIN_HOST      = "cb-connect-${local.region_prefix}-${var.env}.my.connect.aws"
    SMS_HISTORY_ID           = module.connect_cases_stack[0].outputs["oSMSHistoryFieldID"]
  }
  tags = local.lambda_node_default_configurations.tags
}

module "attach_flow_sms_with_case_lambda" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  name                    = local.lambda_names.attach_flow_sms_with_case
  handler                 = local.lambda_node24_default_configurations.handler
  runtime                 = local.lambda_node24_default_configurations.runtime
  local_existing_package  = local.lambda_node24_default_configurations.package
  timeout                 = local.lambda_node24_default_configurations.timeout
  memory_size             = local.lambda_node24_default_configurations.memory_size
  ignore_source_code_hash = local.lambda_node24_default_configurations.ignore_source_code_hash
  attach                  = { policy_jsons = true }
  iam_configuration       = local.lambda_iam_configurations["attach_flow_sms_with_case_lambda_policy"]
  publish                 = true
  kms_key_arn             = module.common_aws_kms_key.key_arn
  logging_configuration   = local.lambda_log_group_configurations
  environment_variables = {
    CHAT_TRANSCRIPT_BUCKET = module.s3_chat_transcript.bucket_id
    DOMAIN_ID              = var.cases_domain_id
    INSTANCE_ID            = local.connect_instance_id
    SMS_HISTORY_FIELD_ID   = module.connect_cases_stack[0].outputs["oSMSHistoryFieldID"]
  }
  tags = local.lambda_node24_default_configurations.tags
}


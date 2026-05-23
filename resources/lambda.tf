# ========================================
# Lambda Functions for KK Backend
# ========================================

# Health Check Lambda
module "kk_health_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-health"
  handler                 = "src/handlers/health.handler"
  runtime                 = local.kk_lambda_common_config.runtime
  local_existing_package  = local.kk_lambda_common_config.package
  timeout                 = local.kk_lambda_common_config.timeout
  memory_size             = local.kk_lambda_common_config.memory_size
  ignore_source_code_hash = local.kk_lambda_common_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_common_config.tags
}

# Portal Chat Start Lambda
module "kk_portal_chat_start_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-portalChatStart"
  handler                 = "src/handlers/portalChat.start"
  runtime                 = local.kk_lambda_common_config.runtime
  local_existing_package  = local.kk_lambda_common_config.package
  timeout                 = local.kk_lambda_common_config.timeout
  memory_size             = local.kk_lambda_common_config.memory_size
  ignore_source_code_hash = local.kk_lambda_common_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_common_config.tags
}

# Portal Chat Send Message Lambda
module "kk_portal_chat_send_message_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-portalChatSendMessage"
  handler                 = "src/handlers/portalChat.sendMessage"
  runtime                 = local.kk_lambda_common_config.runtime
  local_existing_package  = local.kk_lambda_common_config.package
  timeout                 = local.kk_lambda_common_config.timeout
  memory_size             = local.kk_lambda_common_config.memory_size
  ignore_source_code_hash = local.kk_lambda_common_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_common_config.tags
}

# Portal Chat Get Messages Lambda
module "kk_portal_chat_get_messages_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-portalChatGetMessages"
  handler                 = "src/handlers/portalChat.getMessages"
  runtime                 = local.kk_lambda_common_config.runtime
  local_existing_package  = local.kk_lambda_common_config.package
  timeout                 = local.kk_lambda_common_config.timeout
  memory_size             = local.kk_lambda_common_config.memory_size
  ignore_source_code_hash = local.kk_lambda_common_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_common_config.tags
}

# Portal Chat End Lambda
module "kk_portal_chat_end_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-portalChatEnd"
  handler                 = "src/handlers/portalChat.end"
  runtime                 = local.kk_lambda_common_config.runtime
  local_existing_package  = local.kk_lambda_common_config.package
  timeout                 = local.kk_lambda_common_config.timeout
  memory_size             = local.kk_lambda_common_config.memory_size
  ignore_source_code_hash = local.kk_lambda_common_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_common_config.tags
}

# Portal Callback Request Lambda
module "kk_portal_callback_request_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-portalCallbackRequest"
  handler                 = "src/handlers/portalCallback.request"
  runtime                 = local.kk_lambda_common_config.runtime
  local_existing_package  = local.kk_lambda_common_config.package
  timeout                 = local.kk_lambda_common_config.timeout
  memory_size             = local.kk_lambda_common_config.memory_size
  ignore_source_code_hash = local.kk_lambda_common_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_common_config.tags
}

# Portal Contact Submit Lambda
module "kk_portal_contact_submit_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-portalContactSubmit"
  handler                 = "src/handlers/portalContact.submit"
  runtime                 = local.kk_lambda_common_config.runtime
  local_existing_package  = local.kk_lambda_common_config.package
  timeout                 = local.kk_lambda_common_config.timeout
  memory_size             = local.kk_lambda_common_config.memory_size
  ignore_source_code_hash = local.kk_lambda_common_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_common_config.tags
}

# AI Message Lambda
module "kk_ai_message_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-aiMessage"
  handler                 = "src/handlers/aiChat.message"
  runtime                 = local.kk_lambda_common_config.runtime
  local_existing_package  = local.kk_lambda_common_config.package
  timeout                 = local.kk_lambda_common_config.timeout
  memory_size             = local.kk_lambda_common_config.memory_size
  ignore_source_code_hash = local.kk_lambda_common_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_common_config.tags
}

# AI Transfer Lambda
module "kk_ai_transfer_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-aiTransfer"
  handler                 = "src/handlers/agentTransfer.transfer"
  runtime                 = local.kk_lambda_common_config.runtime
  local_existing_package  = local.kk_lambda_common_config.package
  timeout                 = local.kk_lambda_common_config.timeout
  memory_size             = local.kk_lambda_common_config.memory_size
  ignore_source_code_hash = local.kk_lambda_common_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_common_config.tags
}

# AI Bedrock Message Lambda (with longer timeout)
module "kk_ai_bedrock_message_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-aiBedrockMessage"
  handler                 = "src/handlers/bedrockChat.message"
  runtime                 = local.kk_lambda_bedrock_config.runtime
  local_existing_package  = local.kk_lambda_bedrock_config.package
  timeout                 = local.kk_lambda_bedrock_config.timeout
  memory_size             = local.kk_lambda_bedrock_config.memory_size
  ignore_source_code_hash = local.kk_lambda_bedrock_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_bedrock_config.tags
}

# Get Metrics Lambda
module "kk_get_metrics_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-getMetrics"
  handler                 = "src/handlers/metrics.getMetrics"
  runtime                 = local.kk_lambda_common_config.runtime
  local_existing_package  = local.kk_lambda_common_config.package
  timeout                 = local.kk_lambda_common_config.timeout
  memory_size             = local.kk_lambda_common_config.memory_size
  ignore_source_code_hash = local.kk_lambda_common_config.ignore_source_code_hash
  attach                  = local.kk_lambda_iam_config
  iam_configuration = {
    policy_jsons = [data.aws_iam_policy_document.kk_lambda_policy.json]
    role_arn     = module.kk_backend_lambda_role.iam_role_arn
  }
  publish               = true
  kms_key_arn           = module.common_aws_kms_key.key_arn
  logging_configuration = local.lambda_log_group_configurations
  environment_variables = local.kk_lambda_environment
  tags                  = local.kk_lambda_common_config.tags
}

# Note: Due to the large number of Lambda functions (40+), I'm creating the core functions above.
# Additional Lambda functions for agents, queues, contacts, callbacks, bot stats, and admin functions
# should follow the same pattern. Each function would have its own module block with appropriate
# handler, name, and configuration.

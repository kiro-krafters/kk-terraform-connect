# Local values for DynamoDB tables

locals {
  # Region prefix mapping
  region_prefix_map = {
    "us-east-1" = "use1"
    "us-east-2" = "use2"
    "us-west-1" = "usw1"
    "us-west-2" = "usw2"
  }

  region_prefix = local.region_prefix_map[var.region]

  # Common tags for all resources
  tags = {
    Company     = var.company
    Project     = var.project
    Environment = var.env
    Region      = var.region
    ManagedBy   = "Terraform"
  }

  # ========================================
  # KK Backend Configuration
  # ========================================

  # Lambda configuration for KK Backend
  kk_lambda_common_config = {
    handler                 = "index.handler"
    runtime                 = "nodejs20.x"
    package                 = "./lambda_function/kk-backend.zip"
    timeout                 = 6
    memory_size             = 1024
    ignore_source_code_hash = true
    tags                    = local.tags
  }

  kk_lambda_bedrock_config = {
    handler                 = "index.handler"
    runtime                 = "nodejs20.x"
    package                 = "./lambda_function/kk-backend.zip"
    timeout                 = 29
    memory_size             = 1024
    ignore_source_code_hash = true
    tags                    = local.tags
  }

  # Lambda logging configuration
  lambda_log_group_configurations = {
    retention_in_days = 90
    kms_key_id        = module.common_aws_kms_key.key_arn
    log_format        = "JSON"
    log_level         = "INFO"
    sys_log_level     = "INFO"
  }

  # Lambda environment variables
  kk_lambda_environment = {
    STAGE                      = var.env
    CONNECT_INSTANCE_ID        = var.connect_instance_id
    CONNECT_INSTANCE_ARN       = var.connect_instance_arn
    CONNECT_QUEUE_GENERAL_ID   = var.connect_queue_general_id
    CONNECT_QUEUE_CLAIMS_ID    = var.connect_queue_claims_id
    CONNECT_CHAT_FLOW_ID       = var.connect_chat_flow_id
    CONNECT_VOICE_FLOW_ID      = var.connect_voice_flow_id
    COGNITO_USER_POOL_ID       = var.cognito_user_pool_id
    COGNITO_REGION             = var.region
    LEX_BOT_ID                 = var.lex_bot_id
    LEX_BOT_ALIAS_ID           = var.lex_bot_alias_id
    LEX_LOCALE_ID              = "en_US"
    BEDROCK_MODEL_ID           = "anthropic.claude-3-haiku-20240307-v1:0"
    DYNAMODB_SESSIONS_TABLE    = module.kk_chat_sessions.dynamodb_table_id
    DYNAMODB_HISTORY_TABLE     = module.kk_contact_history.dynamodb_table_id
    DYNAMODB_CALLBACKS_TABLE   = module.kk_callbacks.dynamodb_table_id
    DYNAMODB_AUDIT_TABLE       = module.kk_audit_logs.dynamodb_table_id
    PORTAL_ORIGIN              = var.portal_origin
    CCP_ORIGIN                 = var.ccp_origin
    ADMIN_ORIGIN               = var.admin_origin
  }

  # Lambda IAM configuration
  kk_lambda_iam_config = {
    number_of_policy_jsons = 1
    policy_jsons           = [data.aws_iam_policy_document.kk_lambda_policy.json]
  }

  # API Gateway configuration
  kk_backend_api_name = format("kk-backend-%s-%s", local.region_prefix, var.env)
  stage_name          = var.env
}

# ========================================
# Admin Lambda Functions for KK Backend
# ========================================

# Get Agents Lambda
module "kk_get_agents_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-getAgents"
  handler                 = "src/handlers/agents.getAgents"
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

# Update Agent Routing Profile Lambda
module "kk_update_agent_routing_profile_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-updateAgentRoutingProfile"
  handler                 = "src/handlers/agents.updateRoutingProfile"
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

# Update Agent Proficiency Lambda
module "kk_update_agent_proficiency_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-updateAgentProficiency"
  handler                 = "src/handlers/agents.updateProficiency"
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

# Get Queues Lambda
module "kk_get_queues_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-getQueues"
  handler                 = "src/handlers/queues.getQueues"
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

# Update Queue Hours Lambda
module "kk_update_queue_hours_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-updateQueueHours"
  handler                 = "src/handlers/queues.updateHours"
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

# Get Contact History Lambda
module "kk_get_contact_history_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-getContactHistory"
  handler                 = "src/handlers/contacts.getHistory"
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

# Trigger Callback Lambda
module "kk_trigger_callback_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-triggerCallback"
  handler                 = "src/handlers/callback.trigger"
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

# Get Bot Stats Lambda
module "kk_get_bot_stats_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-getBotStats"
  handler                 = "src/handlers/botStats.getStats"
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

# Admin Get CCP Config Lambda
module "kk_admin_get_ccp_config_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminGetCcpConfig"
  handler                 = "src/handlers/adminCcp.getConfig"
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

# Admin List Users Lambda
module "kk_admin_list_users_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminListUsers"
  handler                 = "src/handlers/adminUsers.list"
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

# Admin Create User Lambda
module "kk_admin_create_user_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminCreateUser"
  handler                 = "src/handlers/adminUsers.create"
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

# Admin Get User Lambda
module "kk_admin_get_user_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminGetUser"
  handler                 = "src/handlers/adminUsers.get"
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

# Admin Update User Lambda
module "kk_admin_update_user_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminUpdateUser"
  handler                 = "src/handlers/adminUsers.update"
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

# Admin Delete User Lambda
module "kk_admin_delete_user_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminDeleteUser"
  handler                 = "src/handlers/adminUsers.remove"
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

# Admin Update User Group Lambda
module "kk_admin_update_user_group_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminUpdateUserGroup"
  handler                 = "src/handlers/adminUsers.updateGroup"
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

# Continue with remaining admin Lambda functions...
# (Queue management, routing profiles, security profiles, contact flows, analytics, audit logs)

# Admin List Queues Lambda
module "kk_admin_list_queues_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminListQueues"
  handler                 = "src/handlers/adminQueues.list"
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

# Admin Create Queue Lambda
module "kk_admin_create_queue_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminCreateQueue"
  handler                 = "src/handlers/adminQueues.create"
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

# Admin Update Queue Lambda
module "kk_admin_update_queue_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminUpdateQueue"
  handler                 = "src/handlers/adminQueues.update"
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

# Admin List Routing Profiles Lambda
module "kk_admin_list_routing_profiles_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminListRoutingProfiles"
  handler                 = "src/handlers/adminRoutingProfiles.list"
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

# Admin Create Routing Profile Lambda
module "kk_admin_create_routing_profile_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminCreateRoutingProfile"
  handler                 = "src/handlers/adminRoutingProfiles.create"
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

# Admin Update Routing Profile Lambda
module "kk_admin_update_routing_profile_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminUpdateRoutingProfile"
  handler                 = "src/handlers/adminRoutingProfiles.update"
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

# Admin List Security Profiles Lambda
module "kk_admin_list_security_profiles_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminListSecurityProfiles"
  handler                 = "src/handlers/adminSecurityProfiles.list"
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

# Admin List Contact Flows Lambda
module "kk_admin_list_contact_flows_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminListContactFlows"
  handler                 = "src/handlers/adminContactFlows.list"
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

# Admin Get Historical Analytics Lambda
module "kk_admin_get_historical_analytics_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminGetHistoricalAnalytics"
  handler                 = "src/handlers/adminAnalytics.getHistorical"
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

# Admin Get Contacts Analytics Lambda
module "kk_admin_get_contacts_analytics_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminGetContactsAnalytics"
  handler                 = "src/handlers/adminAnalytics.getContacts"
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

# Admin Get Analytics Summary Lambda
module "kk_admin_get_analytics_summary_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminGetAnalyticsSummary"
  handler                 = "src/handlers/adminAnalytics.getSummary"
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

# Admin Get Audit Logs Lambda
module "kk_admin_get_audit_logs_lambda" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=main"
  name                    = "kk-backend-${var.env}-adminGetAuditLogs"
  handler                 = "src/handlers/adminAuditLogs.get"
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

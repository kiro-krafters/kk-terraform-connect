# KK DynamoDB Tables

# 1. Chat Sessions Table
module "kk_chat_sessions" {
  create_table                          = var.is_primary ? true : false
  source                                = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-dynamodb-table-wrapper?ref=main"
  name                                  = "kk_chat_sessions_${var.env}"
  billing_mode                          = "PAY_PER_REQUEST"
  deletion_protection_enabled           = true
  hash_key                              = "sessionId"
  range_key                             = "timestamp"
  read_capacity                         = 0
  restore_date_time                     = null
  restore_source_name                   = null
  restore_source_table_arn              = null
  restore_to_latest_time                = null
  stream_enabled                        = false
  table_class                           = "STANDARD"
  write_capacity                        = 0
  server_side_encryption_enabled        = true
  server_side_encryption_kms_key_arn    = module.common_aws_kms_key.key_arn
  point_in_time_recovery_enabled        = true
  point_in_time_recovery_period_in_days = 7
  ttl_enabled                           = true
  ttl_attribute_name                    = "expirationTime"
  
  attributes = [
    {
      name = "sessionId"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    },
    {
      name = "customerId"
      type = "S"
    }
  ]
  
  global_secondary_indexes = [
    {
      name               = "CustomerIdIndex"
      hash_key           = "customerId"
      range_key          = "timestamp"
      projection_type    = "ALL"
      read_capacity      = 0
      write_capacity     = 0
      non_key_attributes = []
    }
  ]
  
  tags = local.tags
}

# 2. Contact History Table
module "kk_contact_history" {
  create_table                          = var.is_primary ? true : false
  source                                = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-dynamodb-table-wrapper?ref=main"
  name                                  = "kk_contact_history_${var.env}"
  billing_mode                          = "PAY_PER_REQUEST"
  deletion_protection_enabled           = true
  hash_key                              = "customerId"
  range_key                             = "contactTimestamp"
  read_capacity                         = 0
  restore_date_time                     = null
  restore_source_name                   = null
  restore_source_table_arn              = null
  restore_to_latest_time                = null
  stream_enabled                        = false
  table_class                           = "STANDARD"
  write_capacity                        = 0
  server_side_encryption_enabled        = true
  server_side_encryption_kms_key_arn    = module.common_aws_kms_key.key_arn
  point_in_time_recovery_enabled        = true
  point_in_time_recovery_period_in_days = 7
  ttl_enabled                           = false
  ttl_attribute_name                    = null
  
  attributes = [
    {
      name = "customerId"
      type = "S"
    },
    {
      name = "contactTimestamp"
      type = "N"
    },
    {
      name = "contactId"
      type = "S"
    }
  ]
  
  global_secondary_indexes = [
    {
      name               = "ContactIdIndex"
      hash_key           = "contactId"
      range_key          = null
      projection_type    = "ALL"
      read_capacity      = 0
      write_capacity     = 0
      non_key_attributes = []
    }
  ]
  
  tags = local.tags
}

# 3. Callbacks Table
module "kk_callbacks" {
  create_table                          = var.is_primary ? true : false
  source                                = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-dynamodb-table-wrapper?ref=main"
  name                                  = "kk_callbacks_${var.env}"
  billing_mode                          = "PAY_PER_REQUEST"
  deletion_protection_enabled           = true
  hash_key                              = "callbackId"
  range_key                             = "requestedTime"
  read_capacity                         = 0
  restore_date_time                     = null
  restore_source_name                   = null
  restore_source_table_arn              = null
  restore_to_latest_time                = null
  stream_enabled                        = false
  table_class                           = "STANDARD"
  write_capacity                        = 0
  server_side_encryption_enabled        = true
  server_side_encryption_kms_key_arn    = module.common_aws_kms_key.key_arn
  point_in_time_recovery_enabled        = true
  point_in_time_recovery_period_in_days = 7
  ttl_enabled                           = true
  ttl_attribute_name                    = "expirationTime"
  
  attributes = [
    {
      name = "callbackId"
      type = "S"
    },
    {
      name = "requestedTime"
      type = "N"
    },
    {
      name = "customerId"
      type = "S"
    },
    {
      name = "status"
      type = "S"
    }
  ]
  
  global_secondary_indexes = [
    {
      name               = "CustomerIdIndex"
      hash_key           = "customerId"
      range_key          = "requestedTime"
      projection_type    = "ALL"
      read_capacity      = 0
      write_capacity     = 0
      non_key_attributes = []
    },
    {
      name               = "StatusIndex"
      hash_key           = "status"
      range_key          = "requestedTime"
      projection_type    = "ALL"
      read_capacity      = 0
      write_capacity     = 0
      non_key_attributes = []
    }
  ]
  
  tags = local.tags
}

# 4. Audit Logs Table
module "kk_audit_logs" {
  create_table                          = var.is_primary ? true : false
  source                                = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-dynamodb-table-wrapper?ref=main"
  name                                  = "kk_audit_logs_${var.env}"
  billing_mode                          = "PAY_PER_REQUEST"
  deletion_protection_enabled           = true
  hash_key                              = "logId"
  range_key                             = "timestamp"
  read_capacity                         = 0
  restore_date_time                     = null
  restore_source_name                   = null
  restore_source_table_arn              = null
  restore_to_latest_time                = null
  stream_enabled                        = false
  table_class                           = "STANDARD"
  write_capacity                        = 0
  server_side_encryption_enabled        = true
  server_side_encryption_kms_key_arn    = module.common_aws_kms_key.key_arn
  point_in_time_recovery_enabled        = true
  point_in_time_recovery_period_in_days = 7
  ttl_enabled                           = false
  ttl_attribute_name                    = null
  
  attributes = [
    {
      name = "logId"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    },
    {
      name = "adminUserId"
      type = "S"
    },
    {
      name = "actionType"
      type = "S"
    }
  ]
  
  global_secondary_indexes = [
    {
      name               = "AdminUserIdIndex"
      hash_key           = "adminUserId"
      range_key          = "timestamp"
      projection_type    = "ALL"
      read_capacity      = 0
      write_capacity     = 0
      non_key_attributes = []
    },
    {
      name               = "ActionTypeIndex"
      hash_key           = "actionType"
      range_key          = "timestamp"
      projection_type    = "ALL"
      read_capacity      = 0
      write_capacity     = 0
      non_key_attributes = []
    }
  ]
  
  tags = local.tags
}


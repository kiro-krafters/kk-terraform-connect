# ========================================
# Outputs for KK Backend
# ========================================

# DynamoDB Table Outputs
output "kk_chat_sessions_table_name" {
  description = "Name of the chat sessions DynamoDB table"
  value       = module.kk_chat_sessions.dynamodb_table_id
}

output "kk_chat_sessions_table_arn" {
  description = "ARN of the chat sessions DynamoDB table"
  value       = module.kk_chat_sessions.dynamodb_table_arn
}

output "kk_contact_history_table_name" {
  description = "Name of the contact history DynamoDB table"
  value       = module.kk_contact_history.dynamodb_table_id
}

output "kk_contact_history_table_arn" {
  description = "ARN of the contact history DynamoDB table"
  value       = module.kk_contact_history.dynamodb_table_arn
}

output "kk_callbacks_table_name" {
  description = "Name of the callbacks DynamoDB table"
  value       = module.kk_callbacks.dynamodb_table_id
}

output "kk_callbacks_table_arn" {
  description = "ARN of the callbacks DynamoDB table"
  value       = module.kk_callbacks.dynamodb_table_arn
}

output "kk_audit_logs_table_name" {
  description = "Name of the audit logs DynamoDB table"
  value       = module.kk_audit_logs.dynamodb_table_id
}

output "kk_audit_logs_table_arn" {
  description = "ARN of the audit logs DynamoDB table"
  value       = module.kk_audit_logs.dynamodb_table_arn
}

# Lambda Function Outputs
output "kk_health_lambda_arn" {
  description = "ARN of the health check Lambda function"
  value       = module.kk_health_lambda.lambda_function_arn
}

output "kk_health_lambda_name" {
  description = "Name of the health check Lambda function"
  value       = module.kk_health_lambda.lambda_function_name
}

# IAM Role Outputs
output "kk_backend_lambda_role_arn" {
  description = "ARN of the KK Backend Lambda execution role"
  value       = module.kk_backend_lambda_role.iam_role_arn
}

output "kk_backend_lambda_role_name" {
  description = "Name of the KK Backend Lambda execution role"
  value       = module.kk_backend_lambda_role.iam_role_name
}

# API Gateway Outputs
output "kk_backend_api_id" {
  description = "ID of the KK Backend API Gateway"
  value       = aws_api_gateway_rest_api.kk_backend_api.id
}

output "kk_backend_api_endpoint" {
  description = "Endpoint URL of the KK Backend API Gateway"
  value       = "https://${aws_api_gateway_rest_api.kk_backend_api.id}.execute-api.${var.region}.amazonaws.com/${var.env}"
}

output "kk_backend_api_execution_arn" {
  description = "Execution ARN of the KK Backend API Gateway"
  value       = aws_api_gateway_rest_api.kk_backend_api.execution_arn
}

# S3 Bucket Outputs
output "kk_serverless_deployment_bucket_name" {
  description = "Name of the serverless deployment S3 bucket"
  value       = module.kk_serverless_deployment_bucket.s3_bucket_id
}

output "kk_serverless_deployment_bucket_arn" {
  description = "ARN of the serverless deployment S3 bucket"
  value       = module.kk_serverless_deployment_bucket.s3_bucket_arn
}

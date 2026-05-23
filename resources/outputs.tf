################################
# Lex Bot Outputs
################################

output "lex_bot_ids" {
  description = "Map of Lex bot names to their IDs"
  value       = try({ for k, v in module.lex_bot : k => v.bot_id }, {})
}

output "lex_bot_alias_arns" {
  description = "Map of Lex bot names to their alias ARNs"
  value       = try({ for k, v in module.lex_bot : k => v.bot_alias_arn }, {})
}

################################
# Lex Bot IAM Role Outputs
################################

output "lex_bot_role_arns" {
  description = "Map of Lex bot names to their IAM role ARNs"
  value       = try({ for k, v in module.lex_bot_role : k => v.iam_role_arn }, {})
}

output "lex_bot_role_names" {
  description = "Map of Lex bot names to their IAM role names"
  value       = try({ for k, v in module.lex_bot_role : k => v.iam_role_name }, {})
}

################################
# Lambda Function Outputs
################################

output "lambda_function_arns" {
  description = "Map of Lambda logical names to their ARNs"
  value = try({
    case_event_enrichment    = module.case_event_enrichment_lambda.lambda_function_arn
    intake_dialogue_function = module.intake_dialogue_function_lambda.lambda_function_arn
    get_non_closed_cases     = module.get_non_closed_cases_lambda.lambda_function_arn
    delete_all_cases         = module.delete_all_cases_lambda.lambda_function_arn
    ctr_processor            = module.ctr_processor_lambda.lambda_function_arn
  }, {})
}

################################
# S3 Bucket Outputs
################################

output "s3_bucket_arns" {
  description = "Map of S3 bucket logical names to their ARNs"
  value = try({
    call_recording  = module.s3_call_recording.bucket_arn
    chat_transcript = module.s3_chat_transcript.bucket_arn
    cases_events    = module.s3_cases_events.bucket_arn
  }, {})
}

################################
# KMS Outputs
################################

output "kms_key_arn" {
  description = "KMS key ARN used for buckets and encryption"
  value       = try(module.common_aws_kms_key.key_arn, null)
}

################################
# Kinesis Firehose Outputs
################################

output "cases_firehose_arn" {
  description = "ARN of the Cases event stream Kinesis Firehose"
  value       = try(module.cases_event_stream_firehose.kinesis_firehose_arn, null)
}

output "cases_firehose_role_arn" {
  description = "IAM role ARN used by the Cases Firehose"
  value       = try(module.cases_firehose_role.iam_role_arn, null)
}

output "ctr_firehose_role_arn" {
  description = "IAM role ARN used by the CTR Firehose"
  value       = try(module.ctr_firehose_role.iam_role_arn, null)
}

################################
# Amazon Connect Outputs
################################

output "connect_instance_id" {
  description = "Amazon Connect instance ID"
  value       = try(module.amazon_connect.instance_id, null)
}

output "connect_instance_arn" {
  description = "Amazon Connect instance ARN"
  value = try(
    "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${module.amazon_connect.instance_id}",
    null
  )
}

# output "connect_general_case_id" {
#   description = "General support case id"
#   value       = try(module.connect_cases_stack[0].outputs["oGeneralSupportTemplateId"], null)
# }

################################
# CloudFront Outputs
################################

output "cloudfront_distribution_id" {
  description = "The identifier for the CloudFront distribution"
  value       = try(module.cloudfront[0].cloudfront_distribution_id, null)
}

output "cloudfront_distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the CloudFront distribution"
  value       = try(module.cloudfront[0].cloudfront_distribution_arn, null)
}

output "cloudfront_domain_name" {
  description = "The domain name corresponding to the CloudFront distribution"
  value       = try(module.cloudfront[0].cloudfront_distribution_domain_name, null)
}

################################
# API Gateway Outputs
################################

output "api_gateway_stage_invoke_url" {
  description = "The URL to invoke the API Gateway stage (used to invoke backend)"
  value       = try(module.sms_sender_api_deployment.apigatewayv1_stage_invoke_url, null)
}

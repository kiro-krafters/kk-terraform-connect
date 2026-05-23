module "cases_event_stream_firehose" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-kinesis-firehose?ref=v1.0.0"
  name   = format("%s-cases-event-stream-%s-%s", var.company_prefix, local.region_prefix, var.env)

  input_source = "direct-put"
  destination  = "extended_s3"

  s3_bucket_arn          = module.s3_cases_events.bucket_arn
  s3_prefix              = "cases-events/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  s3_error_output_prefix = "cases-events-errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

  s3_compression_format = "GZIP"
  buffering_size        = 5
  buffering_interval    = 300

  enable_s3_encryption = true
  s3_kms_key_arn       = module.common_aws_kms_key.key_arn

  enable_lambda_transform          = true
  transform_lambda_arn             = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${format("%s-lmda-case-event-enrichment-%s-%s", var.company_prefix, local.region_prefix, var.env)}"
  transform_lambda_buffer_size     = 1
  transform_lambda_buffer_interval = 60
  transform_lambda_number_retries  = 3

  enable_s3_backup          = false
  create_role               = false
  firehose_role             = module.cases_firehose_role.iam_role_arn
  transform_lambda_role_arn = module.cases_firehose_role.iam_role_arn

  tags   = local.tags
  create = true

  depends_on = [
    module.cases_firehose_role,
    module.case_event_enrichment_lambda,
    module.s3_cases_events
  ]
}


module "firehose_connect" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-kinesis-firehose?ref=v1.0.0"
  name   = format("%s-firehose-contact-trace-records-%s-%s", var.company_prefix, local.region_prefix, var.env)

  input_source = "kinesis"
  destination  = "extended_s3"

  kinesis_source_stream_arn   = module.kinesis.kinesis_stream_arn
  kinesis_source_is_encrypted = true
  kinesis_source_kms_arn      = module.common_aws_kms_key.key_arn

  s3_bucket_arn          = module.s3_contact_trace_records.bucket_arn
  s3_prefix              = "amazon/connect/contact-trace-records/"
  s3_error_output_prefix = "amazon/connect/contact-trace-records-errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  s3_compression_format  = "GZIP"

  append_delimiter_to_record = true
  buffering_size             = 5
  buffering_interval         = 300

  enable_s3_encryption = true
  s3_kms_key_arn       = module.common_aws_kms_key.key_arn

  enable_lambda_transform          = true
  transform_lambda_arn             = module.ctr_processor_lambda.lambda_function_arn
  transform_lambda_role_arn        = module.ctr_firehose_role.iam_role_arn
  transform_lambda_buffer_size     = 1
  transform_lambda_buffer_interval = 60
  transform_lambda_number_retries  = 3

  create_role   = false
  firehose_role = module.ctr_firehose_role.iam_role_arn

  tags   = local.tags
  create = true

  depends_on = [
    module.kinesis,
    module.s3_contact_trace_records,
    module.ctr_firehose_role,
    module.ctr_processor_lambda
  ]
}

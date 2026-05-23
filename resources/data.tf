data "aws_caller_identity" "current" {}

data "aws_connect_instance" "amazon_connect" {
  count = var.create_instance ? 0 : 1

  instance_alias = "${var.company_prefix}-connect-${local.region_prefix}-${var.env}"
}

data "aws_connect_prompt" "off_for_holidays_prompt" {
  instance_id = local.connect_instance_id
  name        = "cb_off_for_holidays"
}
data "aws_connect_prompt" "out_of_hours_prompt" {
  instance_id = local.connect_instance_id
  name        = "cb_out_of_hours"
}
data "aws_connect_prompt" "silence_prompt" {
  instance_id = local.connect_instance_id
  name        = "cb_silence"
}
data "aws_connect_prompt" "beep_prompt" {
  instance_id = local.connect_instance_id
  name        = "Beep.wav"
}
data "aws_connect_prompt" "inbound_call_connecting_to_navigator_prompt" {
  instance_id = local.connect_instance_id
  name        = "cb_inbound_call_connecting_to_navigator"
}
data "aws_connect_prompt" "inbound_call_navigator_busy_prompt" {
  instance_id = local.connect_instance_id
  name        = "cb_inbound_call_navigator_busy"
}
data "aws_connect_prompt" "music_pop_throw_yourself_in_front_of_it_prompt" {
  instance_id = local.connect_instance_id
  name        = "Music_Pop_ThrowYourselfInFrontOfIt_Inst.wav"
}

data "aws_connect_hours_of_operation" "cb_basic_hours" {
  instance_id = local.connect_instance_id
  name        = "Basic Hours"
}

data "aws_connect_contact_flow" "default_outbound_flow" {
  instance_id = local.connect_instance_id
  name        = "Default outbound"
}

data "aws_connect_contact_flow" "cb_outbound_flow" {
  instance_id = local.connect_instance_id
  name        = "cb_outbound_flow"
}

data "aws_iam_policy_document" "case_event_enrichment_lambda_policy" {
  version = "2012-10-17"
  # Allow reading Cases templates/layouts
  statement {
    sid    = "AllowCasesTemplates"
    effect = "Allow"
    actions = [
      "cases:GetTemplate",
      "cases:GetLayout"
    ]
    resources = ["*"]
  }

  # Allow CloudWatch Logs for Lambda function
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
    ]
  }

  # Allow Cases read actions scoped to domain
  statement {
    sid    = "AllowCasesDomainAccess"
    effect = "Allow"
    actions = [
      "cases:GetCaseAuditEvents",
      "cases:ListFields",
      "cases:GetCase"
    ]
    resources = [
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/case/*",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/field/*"
    ]
  }

  # Allow Connect to describe users in the instance
  statement {
    sid     = "AllowConnectDescribeUser"
    effect  = "Allow"
    actions = ["connect:DescribeUser"]
    resources = [
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}/agent/*"
    ]
  }
}

data "aws_iam_policy_document" "cases_firehose_combined" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      module.s3_cases_events.bucket_arn,
      "${module.s3_cases_events.bucket_arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kinesisfirehose/*",
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kinesisfirehose/*:log-stream:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}

data "aws_iam_policy_document" "ctr_firehose_combined" {
  version = "2012-10-17"

  statement {
    sid    = "AllowCtrS3Delivery"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      module.s3_contact_trace_records.bucket_arn,
      "${module.s3_contact_trace_records.bucket_arn}/*",
    ]
  }

  statement {
    sid    = "AllowCtrFirehoseLogs"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kinesisfirehose/*",
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kinesisfirehose/*:log-stream:*"
    ]
  }

  statement {
    sid    = "AllowCtrS3Kms"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }

  statement {
    sid    = "AllowCtrKinesisSourceRead"
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = [
      module.kinesis.kinesis_stream_arn
    ]
  }

  statement {
    sid    = "AllowInvokeCtrProcessorLambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${local.lambda_names.ctr_processor}",
      "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${local.lambda_names.ctr_processor}:*"
    ]
  }
}


# IAM policy for get_non_closed_cases Lambda: Logs + Cases search scoped to domain
data "aws_iam_policy_document" "get_non_closed_cases_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid     = "AllowCloudWatchLogsCreate"
    effect  = "Allow"
    actions = ["logs:CreateLogGroup"]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid     = "AllowCloudWatchLogsPut"
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.get_non_closed_cases}:*"
    ]
  }

  statement {
    sid     = "AllowSearchCasesOnDomainAndFields"
    effect  = "Allow"
    actions = ["cases:SearchCases"]
    resources = [
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/field/*"
    ]
  }
}

data "aws_iam_policy_document" "intake_dialogue_function_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid     = "AllowCloudWatchLogsCreate"
    effect  = "Allow"
    actions = ["logs:CreateLogGroup"]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid     = "AllowCloudWatchLogsPut"
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.intake_dialogue_function}:*"
    ]
  }

  statement {
    sid     = "AllowGetAndUpdateContactAttributes"
    effect  = "Allow"
    actions = ["connect:GetContactAttributes", "connect:UpdateContactAttributes"]
    resources = [
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}/contact/*"
    ]
  }
}

data "aws_iam_policy_document" "delete_all_cases_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid     = "AllowCloudWatchLogsCreate"
    effect  = "Allow"
    actions = ["logs:CreateLogGroup"]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid     = "AllowCloudWatchLogsPut"
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.delete_all_cases}:*"
    ]
  }

  statement {
    sid     = "AllowSearchCasesOnDomainAndFields"
    effect  = "Allow"
    actions = ["cases:SearchCases"]
    resources = [
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/field/*"
    ]
  }

  statement {
    sid     = "AllowDeleteCasesOnDomainAndCases"
    effect  = "Allow"
    actions = ["cases:DeleteCase"]
    resources = [
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/case/*"
    ]
  }
}
data "aws_iam_policy_document" "connect_backup_lambda_policy" {
  version = "2012-10-17"

  #
  # CloudWatch Logs – create log group
  #
  statement {
    sid    = "AllowCloudWatchLogsCreate"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  #
  # CloudWatch Logs – write logs
  #
  statement {
    sid    = "AllowCloudWatchLogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.connect_backup}:*"
    ]
  }

  #
  # Amazon Connect – read-only metadata backup
  #
  statement {
    sid    = "AllowAmazonConnectRead"
    effect = "Allow"
    actions = [
      "connect:ListContactFlows",
      "connect:DescribeContactFlow",
      "connect:ListHoursOfOperations",
      "connect:DescribeHoursOfOperation",
      "connect:ListQueues",
      "connect:DescribeQueue",
      "connect:ListRoutingProfiles",
      "connect:DescribeRoutingProfile"
    ]
    resources = [
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}",
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}/*",
    ]
  }

  #
  # S3 – write backups to bucket (created in same repo via module)
  #
  statement {
    sid    = "AllowS3BackupWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "${module.s3_connect_backup_bucket.bucket_arn}/*"
    ]
  }
  statement {
    sid    = "AllowKMSForBackupEncryption"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}

data "aws_iam_policy_document" "sms_backend_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowCloudWatchLogsCreate"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogsPut"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.sms_backend}:*"
    ]
  }

  statement {
    sid    = "AllowCasesOperations"
    effect = "Allow"
    actions = [
      "cases:SearchCases",
      "cases:UpdateCase",
      "cases:CreateRelatedItem"
    ]
    resources = [
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/*",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/field/*"
    ]
  }

  statement {
    sid    = "AllowCustomerProfilesSearch"
    effect = "Allow"
    actions = [
      "profile:SearchProfiles"
    ]
    resources = [
      "arn:aws:profile:${var.region}:${data.aws_caller_identity.current.account_id}:domains/cb-customer-profile-${var.env}"
    ]
  }

  statement {
    sid    = "AllowDynamoDBOperations"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"

    ]
    resources = [
      "${module.connect_inbound_outbound_sms_tracking.dynamodb_table_arn}",
      "${module.connect_outbound_customer_sms.dynamodb_table_arn}",
      "${module.case_view_status.dynamodb_table_arn}"
    ]
  }

  statement {
    sid    = "AllowSendTextMessage"
    effect = "Allow"
    actions = [
      "sms-voice:SendTextMessage"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      "${module.common_aws_kms_key.key_arn}"
    ]
  }
}

data "aws_iam_policy_document" "bot_alias_policy" {
  for_each = local.lex_bots_with_lambda_arn
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_number}:log-group:/*"]
  }
}

data "aws_iam_policy_document" "lex_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lexv2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lex_resource_policy" {
  for_each = local.lex_bots_with_lambda_arn

  statement {
    sid    = "connect-us-east-1-${each.key}"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["connect.amazonaws.com"]
    }

    actions = [
      "lex:RecognizeText",
      "lex:StartConversation"
    ]

    resources = [
      "arn:aws:lex:${var.region}:${var.account_number}:bot-alias/${module.lex_bot[each.key].bot_id}/TSTALIASID",
      "arn:aws:lex:${var.region}:${var.account_number}:bot/${module.lex_bot[each.key].bot_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [var.account_number]
    }

    condition {
      test     = "ArnEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:connect:${var.region}:${var.account_number}:instance/${local.connect_instance_id}"]
    }
  }
}


data "aws_iam_policy_document" "cases_eventbridge_firehose_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowEventBridgeToPutIntoFirehose"
    effect = "Allow"

    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]

    resources = [
      module.cases_event_stream_firehose.kinesis_firehose_arn
    ]
  }
}

data "aws_iam_policy_document" "glue_service_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowGlueS3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      module.s3_cases_events.bucket_arn,
      "${module.s3_cases_events.bucket_arn}/*",
      module.s3_glue_database_storage.bucket_arn,
      "${module.s3_glue_database_storage.bucket_arn}/*"
    ]
  }
  statement {
    sid    = "AllowGlueKMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = [
      "${module.common_aws_kms_key.key_arn}"
    ]
  }

  statement {
    sid    = "AllowGlueCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/*"
    ]
  }
}
data "aws_iam_policy_document" "firehose_lambda_invoke_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowInvokeLambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${format("%s-lmda-case-event-enrichment-%s-%s", var.company_prefix, local.region_prefix, var.env)}",
      "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${format("%s-lmda-case-event-enrichment-%s-%s", var.company_prefix, local.region_prefix, var.env)}:*"
    ]
  }
}

data "aws_iam_policy_document" "glue_trust_policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "cases_eventbridge_trust_policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "firehose_trust_policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "connect_backup_eventbridge_trust_policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "connect_backup_eventbridge_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowEventBridgeToInvokeLambda"
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      module.connect_backup_lambda.lambda_function_arn,
      "${module.connect_backup_lambda.lambda_function_arn}:*"
    ]
  }
}

data "aws_iam_policy_document" "sms_sender_backend_bucket_policy" {
  version = "2012-10-17"
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${module.s3_sms_sender_bucket.bucket_arn}/*"
    ]
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values = [
        "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${try(module.cloudfront[0].cloudfront_distribution_id, "")}"
      ]
    }
  }
}

data "aws_iam_policy_document" "case_management_backend_bucket_policy" {
  version = "2012-10-17"
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${module.s3_case_management_bucket.bucket_arn}/*"
    ]
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values = [
        "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${try(module.case_management_cloudfront[0].cloudfront_distribution_id, "")}"
      ]
    }
  }
}

data "aws_iam_policy_document" "vm_recording_processor_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowS3VoicemailWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging"
    ]
    resources = [
      "${module.s3_voicemail_recording.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowKinesisRead"
    effect = "Allow"
    actions = [
      "kinesis:ListShards",
      "kinesis:GetRecords",
      "kinesis:DescribeStream",
      "kinesis:DescribeStreamSummary",
      "kinesis:SubscribeToShard",
      "kinesis:GetShardIterator",
      "kinesis:ListStreams"
    ]
    resources = [
      module.kinesis.kinesis_stream_arn
    ]
  }

  statement {
    sid    = "AllowS3ConnectRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:ListBucket"
    ]
    resources = [
      "${module.s3_call_recording.bucket_arn}/*",
      module.s3_call_recording.bucket_arn
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.recording_processor}:*"
    ]
  }

  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}

data "aws_iam_policy_document" "vm_transcriber_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowS3VoicemailRecordingRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging"
    ]
    resources = [
      "${module.s3_voicemail_recording.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowTranscribeStartJob"
    effect = "Allow"
    actions = [
      "transcribe:StartTranscriptionJob"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowS3VoicemailTranscriptionWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging"
    ]
    resources = [
      "${module.s3_voicemail_transcription.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.transcriber}:*"
    ]
  }

  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:Encrypt"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}

data "aws_iam_policy_document" "vm_transcribe_error_handler_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowS3VoicemailTranscriptionWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging"
    ]
    resources = [
      "${module.s3_voicemail_transcription.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.transcribe_error_handler}:*"
    ]
  }

  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:Encrypt"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}

data "aws_iam_policy_document" "vm_packager_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowVoicemailOperations"
    effect = "Allow"
    actions = [
      "connect:DescribeQueue",
      "connect:GetContactAttributes",
      "connect:ListUsers",
      "connect:StartTaskContact",
      "connect:SearchUsers",
      "connect:UpdateContactAttributes",
      "connect:DescribeUser",
      "connect:ListUserProficiencies"
    ]
    resources = [
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}",
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}/user/*",
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}/agent/*",
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}/queue/*",
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}/contact/*",
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}/contact-flow/*"
    ]
  }

  statement {
    sid    = "AllowBedrockAccess"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = [
      "arn:aws:bedrock:*:${data.aws_caller_identity.current.account_id}:inference-profile/*",
      "arn:aws:bedrock:*::foundation-model/*"
    ]
  }

  statement {
    sid    = "AllowS3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging"
    ]
    resources = [
      "${module.s3_voicemail_recording.bucket_arn}/*",
      "${module.s3_voicemail_transcription.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowTranscribeDelete"
    effect = "Allow"
    actions = [
      "transcribe:DeleteTranscriptionJob"
    ]
    resources = [
      "arn:aws:transcribe:${var.region}:${data.aws_caller_identity.current.account_id}:transcription-job/vmx3_*"
    ]
  }

  statement {
    sid    = "AllowCustomerProfiles"
    effect = "Allow"
    actions = [
      "profile:SearchProfiles"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCases"
    effect = "Allow"
    actions = [
      "cases:CreateCase",
      "cases:CreateRelatedItem"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowInvokePresigner"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${local.lambda_names.presigner}"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.vm_packager}:*"
    ]
  }

  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:Encrypt"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}

data "aws_iam_policy_document" "vm_presigner_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowVoicemailAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.s3_voicemail_recording.bucket_arn,
      "${module.s3_voicemail_recording.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowSecretAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.company_prefix}-scrt-vm-access-secrets-${local.region_prefix}-${var.env}-*",
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:*-scrt-vm-access-secrets-*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.presigner}:*"
    ]
  }

  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}

data "aws_iam_policy_document" "vm_presigner_user_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowS3GetObject"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${module.s3_voicemail_recording.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowLogsOperations"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}

data "aws_iam_policy_document" "vm_voicemail_timestamper_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.vm_voicemail_timestamper}:*"
    ]
  }
}

data "aws_iam_policy_document" "inbound_sms_tracking_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowCloudWatchLogsCreate"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.inbound_sms_tracking}:*"
    ]
  }

  statement {
    sid    = "AllowCasesOperations"
    effect = "Allow"
    actions = [
      "cases:UpdateCase",
      "cases:CreateRelatedItem",
      "cases:GetCase"
    ]
    resources = [
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/*",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/field/*"
    ]
  }

  statement {
    sid    = "AllowDynamoDBOperations"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:Query"
    ]
    resources = [
      module.connect_inbound_outbound_sms_tracking.dynamodb_table_arn,
      module.connect_outbound_customer_sms.dynamodb_table_arn
    ]
  }

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}

data "aws_iam_policy_document" "ctr_processor_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowCloudWatchLogsCreate"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.ctr_processor}:*"
    ]
  }

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}

data "aws_iam_policy_document" "case_management_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowCloudWatchLogsCreate"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.case_management}:*"
    ]
  }

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = [
      module.common_aws_kms_key.key_arn,
      "${module.common_aws_kms_key.key_arn}/*"
    ]
  }
  statement {
    sid    = "AllowCasesOperations"
    effect = "Allow"
    actions = [
      "cases:SearchCases",
      "cases:GetCase",
      "cases:GetTemplate",
      "cases:GetLayout",
      "cases:CreateCase",
      "cases:UpdateCase",
      "cases:ListCases",
      "cases:BatchGetField",
      "cases:ListFieldOptions",
      "cases:ListFields",
      "cases:SearchAllRelatedItems",
      "cases:SearchRelatedItems",
      "cases:TagResource",
      "cases:UntagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowConnectAndProfileRead"
    effect = "Allow"
    actions = [
      "connect:DescribeUser",
      "connect:ListUsers",
      "profile:BatchGetProfile",
      "profile:GetProfile",
      "profile:SearchProfiles",
      "profile:UpdateProfile",
      "profile:CreateProfile",
      "connect:DescribeContact"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowConnectRead"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:BatchGetItem"
    ]
    resources = [
      "${module.case_view_status.dynamodb_table_arn}"
    ]
  }

}


data "aws_iam_policy_document" "attach_flow_sms_with_case_lambda_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowCloudWatchLogsCreate"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_names.attach_flow_sms_with_case}:*"
    ]
  }

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = [
      module.common_aws_kms_key.key_arn,
      "${module.common_aws_kms_key.key_arn}/*"
    ]
  }

  statement {
    sid    = "AllowS3ReadChatTranscriptObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${module.s3_chat_transcript.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowCasesAndConnectContactScopedAccess"
    effect = "Allow"
    actions = [
      "cases:UpdateCase",
      "cases:GetCase",
      "connect:DescribeContact"
    ]
    resources = [
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/*",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/case/*",
      "arn:aws:cases:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cases_domain_id}/field/*",
      "arn:aws:connect:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${local.connect_instance_id}/contact/*"
    ]
  }


}

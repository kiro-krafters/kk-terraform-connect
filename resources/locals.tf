locals {
  region_prefix_map = {
    "af-south-1"     = "afs1"
    "ap-east-1"      = "ape1"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ap-south-1"     = "aps1"
    "ap-south-2"     = "aps2"
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ap-southeast-5" = "apse5"
    "ap-southeast-7" = "apse7"
    "ca-central-1"   = "cac1"
    "ca-west-1"      = "caw1"
    "cn-north-1"     = "cnn1"
    "cn-northwest-1" = "cnnw1"
    "eu-central-1"   = "euc1"
    "eu-central-2"   = "euc2"
    "eu-north-1"     = "eun1"
    "eu-south-1"     = "eus1"
    "eu-south-2"     = "eus2"
    "eu-west-1"      = "euw1"
    "eu-west-2"      = "euw2"
    "eu-west-3"      = "euw3"
    "il-central-1"   = "ilc1"
    "me-central-1"   = "mec1"
    "me-south-1"     = "mes1"
    "mx-central-1"   = "mxc1"
    "sa-east-1"      = "sae1"
    "us-east-1"      = "use1"
    "us-east-2"      = "use2"
    "us-gov-east-1"  = "usge1"
    "us-gov-west-1"  = "usgw1"
    "us-west-1"      = "usw1"
    "us-west-2"      = "usw2"
  }

  is_primary    = var.region == "us-east-1"
  region_prefix = local.region_prefix_map["${var.region}"]

  # Database name for cases
  cases_database_name = format("%s-glue-cases-db-%s-%s", var.company_prefix, local.region_prefix, var.env)

  # tables need partition keys listed in order; Terraform maps are sorted
  # alphabetically by key so we build an ordered list and then convert it
  # to a map with numeric prefixes.  See `glue.tf` for usage.
  cases_events_partitions_ordered = [
    { name = "year", type = "string" },
    { name = "month", type = "string" },
    { name = "day", type = "string" },
  ]

  cases_events_partition_keys = {
    for idx, p in local.cases_events_partitions_ordered :
    format("%02d-%s", idx, p.name) => p
  }

  connect_instance_id                 = var.create_instance ? try(module.amazon_connect.instance_id, "") : try(data.aws_connect_instance.amazon_connect[0].id, "")
  call_recording_bucket_name          = format("%s-s3-call-recording-%s-%s", var.company_prefix, local.region_prefix, var.env)
  chat_transcript_bucket_name         = format("%s-s3-chat-transcript-%s-%s", var.company_prefix, local.region_prefix, var.env)
  server_access_logs_bucket_name      = format("%s-s3-server-access-logs-%s-%s", var.company_prefix, local.region_prefix, var.env)
  sms_sender_bucket_name              = format("%s-s3-sms-sender-%s-%s", var.company_prefix, local.region_prefix, var.env)
  sms_sender_bucket_origin            = format("%s-s3-sms-sender-%s-%s", var.company_prefix, local.region_prefix, var.env)
  s3_case_management_bucket           = format("%s-s3-case-management-%s-%s", var.company_prefix, local.region_prefix, var.env)
  s3_case_management_bucket_origin    = format("%s-s3-case-management-%s-%s", var.company_prefix, local.region_prefix, var.env)
  voicemail_recording_bucket_name     = format("%s-s3-voicemail-recording-%s-%s", var.company_prefix, local.region_prefix, var.env)
  voicemail_transcription_bucket_name = format("%s-s3-voicemail-transcription-%s-%s", var.company_prefix, local.region_prefix, var.env)

  sms_backend_apig_name     = format("%s-apig-sms-sender-%s-%s", var.company_prefix, local.region_prefix, var.env)
  case_management_apig_name = format("%s-apig-case-management-%s-%s", var.company_prefix, local.region_prefix, var.env)

  stage_name = var.env

  origin_access_control = {
    "${local.sms_sender_bucket_name}" = {
      description      = "Origin Access Control for S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    "${local.sms_sender_bucket_origin}" = {
      domain_name               = "${local.sms_sender_bucket_name}.s3.${var.region}.amazonaws.com"
      origin_id                 = "${local.sms_sender_bucket_origin}"
      origin_access_control_key = "${local.sms_sender_bucket_name}"
    }
    "${local.sms_backend_apig_name}" = {
      domain_name = "${module.sms_sender_api.apigatewayv1_api_id}.execute-api.${var.region}.amazonaws.com"
      origin_id   = "${local.sms_backend_apig_name}"
      origin_path = "/${local.stage_name}"

      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  custom_error_response = [
    {
      error_code            = 403
      response_code         = 403
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    },
    {
      error_code            = 404
      response_code         = 404
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    }
  ]

  default_cache_behavior = {
    target_origin_id       = "${local.sms_sender_bucket_origin}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_name = "Managed-CachingOptimized"
  }

  ordered_cache_behavior = [
    {
      target_origin_id       = "${local.sms_backend_apig_name}"
      path_pattern           = "/api/*"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]

      cache_policy_name            = "Managed-CachingDisabled"
      origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
      response_headers_policy_name = "Managed-SimpleCORS"
    }
  ]

  restrictions = {
    geo_restriction = {
      restriction_type = "none"
      locations        = []
    }
  }

  #case management distribution 
  origin_access_control_cm = {
    "${local.s3_case_management_bucket}" = {
      description      = "Origin Access Control for S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin_cm = {
    "${local.sms_sender_bucket_origin}" = {
      domain_name               = "${local.s3_case_management_bucket}.s3.${var.region}.amazonaws.com"
      origin_id                 = "${local.s3_case_management_bucket_origin}"
      origin_access_control_key = "${local.s3_case_management_bucket}"
    }
    "${local.case_management_apig_name}" = {
      domain_name = "${module.case_management_api.apigatewayv1_api_id}.execute-api.${var.region}.amazonaws.com"
      origin_id   = "${local.case_management_apig_name}"
      origin_path = "/${local.stage_name}"

      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
    "${local.sms_backend_apig_name}" = {
      domain_name = "${module.sms_sender_api.apigatewayv1_api_id}.execute-api.${var.region}.amazonaws.com"
      origin_id   = "${local.sms_backend_apig_name}"
      origin_path = "/${local.stage_name}"

      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior_cm = {
    target_origin_id       = "${local.s3_case_management_bucket_origin}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_name = "Managed-CachingOptimized"
  }

  cloudfront_functions_cm = {
    rewrite_sms_api = {
      name    = format("%s-rewrite-sms-api-%s-%s", var.company_prefix, local.region_prefix, var.env)
      runtime = "cloudfront-js-2.0"
      publish = true
      code    = file("${path.module}/cloudfront-functions/rewrite-sms-api.js")
    }
  }

  ordered_cache_behavior_cm = [
    {
      target_origin_id       = "${local.sms_backend_apig_name}"
      path_pattern           = "/sms-api/*"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]

      cache_policy_name            = "Managed-CachingDisabled"
      origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
      response_headers_policy_name = "Managed-SimpleCORS"
      function_association = {
        rewrite_sms_api = {
          event_type   = "viewer-request"
          function_arn = "arn:aws:cloudfront::${var.account_number}:function/${var.company_prefix}-rewrite-sms-api-${local.region_prefix}-${var.env}"
        }
      }
    },
    {
      target_origin_id       = "${local.case_management_apig_name}"
      path_pattern           = "/api/*"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]

      cache_policy_name            = "Managed-CachingDisabled"
      origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
      response_headers_policy_name = "Managed-SimpleCORS"
    }
  ]
  file_hash_map = {
    "cases_field_and_templates.yaml"              = filesha256("cloudformation-templates/cases_field_and_templates.yaml")
    "connect_prompts.yaml"                        = filesha256("cloudformation-templates/connect_prompts.yaml")
    "data_table.yaml"                             = filesha256("cloudformation-templates/data_table.yaml")
    "cb_security_profiles.yaml"                   = filesha256("cloudformation-templates/cb_security_profiles.yaml")
    "cb-off-for-holidays.wav"                     = filesha256("prompts/cb-off-for-holidays.wav")
    "cb-out-of-hours.wav"                         = filesha256("prompts/cb-out-of-hours.wav")
    "cb-silence-prompt.wav"                       = filesha256("prompts/cb-silence-prompt.wav")
    "cb-inbound-call-connecting-to-navigator.wav" = filesha256("prompts/cb-inbound-call-connecting-to-navigator.wav")
    "cb-inbound-call-navigator-busy.wav"          = filesha256("prompts/cb-inbound-call-navigator-busy.wav")
  }

  lex_bot_hashes = {
    for k, v in local.lex_bots_with_lambda_arn : v.lex_json_file => filesha256("./bot_files/${v.lex_json_file}")
  }

  s3_cfn_objects_map = {
    "object1" = {
      key         = "${local.region_prefix}/cases/cb-cases-field-template-${local.file_hash_map["cases_field_and_templates.yaml"]}.yaml"
      file_source = "cloudformation-templates/cases_field_and_templates.yaml"
    }
    "object2" = {
      key         = "${local.region_prefix}/prompts/connect-prompts-template-${local.file_hash_map["connect_prompts.yaml"]}.yaml"
      file_source = "cloudformation-templates/connect_prompts.yaml"
    }
    "object3" = {
      key         = "${local.region_prefix}/datatable/cb-data-table-${local.file_hash_map["data_table.yaml"]}.yaml"
      file_source = "cloudformation-templates/data_table.yaml"
    }
    "object4" = {
      key         = "${local.region_prefix}/security-profiles/cb-security-profiles-${local.file_hash_map["cb_security_profiles.yaml"]}.yaml"
      file_source = "cloudformation-templates/cb_security_profiles.yaml"
    }
  }

  s3_prompt_objects_map = {
    "object1" = {
      key         = "${local.region_prefix}/prompts/cb-off-for-holidays-${local.file_hash_map["cb-off-for-holidays.wav"]}.wav"
      file_source = "prompts/cb-off-for-holidays.wav"
    }
    "object2" = {
      key         = "${local.region_prefix}/prompts/cb-out-of-hours-${local.file_hash_map["cb-out-of-hours.wav"]}.wav"
      file_source = "prompts/cb-out-of-hours.wav"
    }
    "object3" = {
      key         = "${local.region_prefix}/prompts/cb-silence-prompt-${local.file_hash_map["cb-silence-prompt.wav"]}.wav"
      file_source = "prompts/cb-silence-prompt.wav"
    }
    "object4" = {
      key         = "${local.region_prefix}/prompts/cb-inbound-call-navigator-busy-${local.file_hash_map["cb-inbound-call-navigator-busy.wav"]}.wav"
      file_source = "prompts/cb-inbound-call-navigator-busy.wav"
    }
    "object5" = {
      key         = "${local.region_prefix}/prompts/cb-inbound-call-connecting-to-navigator-${local.file_hash_map["cb-inbound-call-connecting-to-navigator.wav"]}.wav"
      file_source = "prompts/cb-inbound-call-connecting-to-navigator.wav"
    }

  }

  lambda_default_configurations = {
    handler                 = "lambda_function.lambda_handler"
    runtime                 = "python3.12"
    package                 = "./lambda_function/lambda_function.zip"
    timeout                 = 900
    memory_size             = 512
    ignore_source_code_hash = true
    tags                    = local.tags
  }

  lambda_node_default_configurations = {
    handler                 = "index.handler"
    runtime                 = "nodejs22.x"
    package                 = "./lambda_function/lambda_node_function.zip"
    timeout                 = 900
    memory_size             = 512
    ignore_source_code_hash = true
    tags                    = local.tags
  }
  lambda_node24_default_configurations = {
    handler                 = "index.handler"
    runtime                 = "nodejs24.x"
    package                 = "./lambda_function/lambda_node_function.zip"
    timeout                 = 900
    memory_size             = 512
    ignore_source_code_hash = true
    tags                    = local.tags
  }
  lambda_log_group_configurations = {
    retention_in_days = 90
    kms_key_id        = module.common_aws_kms_key.key_arn
    log_format        = "JSON"
    log_level         = "INFO"
    sys_log_level     = "INFO"
  }

  s3_lifecycle_rules = [
    {
      id     = "s3-lifecycle-rule-v1"
      status = "Enabled"
      transition = [
        {
          days          = 1095 # 3 year
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 2555 # 7 years
      }
    }
  ]

  s3_connect_backup_lifecycle_rules = [
    {
      id     = "s3-connect-backup-lifecycle-rule-v1"
      status = "Enabled"
      transition = [
        {
          days          = 90 # 90 days
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 365 # 1 years
      }
    }
  ]

  s3_access_logs_lifecycle_rules = [
    {
      id     = "s3-access-logs-lifecycle-rule-v1"
      status = "Enabled"
      transition = [
        {
          days          = 90 # 90 days
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 365 # 1 years
      }

    }
  ]
  key_statements = [
    {
      sid = "Allow S3 to use the key for encryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["s3.amazonaws.com"]
        }
      ]
      conditions = [
        {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws:s3:arn"
          values = [
            "arn:aws:s3:::${local.call_recording_bucket_name}/*",
            "arn:aws:s3:::${local.chat_transcript_bucket_name}/*",
            "arn:aws:s3:::cb-s3-connect-${local.region_prefix}-${var.env}/*",
            "arn:aws:s3:::${local.voicemail_recording_bucket_name}/*",
            "arn:aws:s3:::${local.voicemail_transcription_bucket_name}/*"
          ]
        },
        {
          test     = "StringEquals"
          variable = "kms:ViaService"
          values = [
            "s3.${var.region}.amazonaws.com"
          ]
        }
      ]
    },
    {
      sid = "Allow connect to use the key for encryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["connect.amazonaws.com"]
        }
      ]
    },
    {
      sid = "Allow Secrets Manager to use the key for encryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["secretsmanager.amazonaws.com"]
        }
      ]
    },
    {
      sid = "Allow Glue to use the key for encryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["glue.amazonaws.com"]
        }
      ]
    },
    {
      sid = "Allow Cloudwatch, Logs to use the key for encryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudwatch.amazonaws.com", "logs.amazonaws.com"]
        }
      ]
    },
    {
      sid = "Allow Firehose to use the key for encryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["firehose.amazonaws.com"]
        }
      ]
    },
    {
      sid = "Allow Lambda to use the key for encryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["lambda.amazonaws.com"]
        }
      ]
    },
    {
      sid = "Allow Athena to use the key for encryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["athena.amazonaws.com"]
        }
      ]
    },
    {
      sid = "Allow CloudFront to use the key for encryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudfront.amazonaws.com"]
        }
      ]
    },
    {
      sid = "Allow QuickSight service to use the key for decryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["quicksight.amazonaws.com"]
        }
      ]
    },
    {
      sid = "Allow QuickSight service role to use the key for decryption"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      ]
      conditions = [
        {
          test     = "ArnLike"
          variable = "aws:PrincipalArn"
          values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-quicksight-service-role-*"]
        }
      ]
    }
  ]

  instance_storage_configs = {
    CALL_RECORDINGS = {
      storage_type = "S3"
      s3_config = {
        bucket_name   = module.s3_call_recording.bucket_id
        bucket_prefix = "call_recordings"
        encryption_config = {
          encryption_type = "KMS"
          key_id          = module.common_aws_kms_key.key_arn
        }
      }
    }
    CHAT_TRANSCRIPTS = {
      storage_type = "S3"
      s3_config = {
        bucket_name   = module.s3_chat_transcript.bucket_id
        bucket_prefix = "chat_transcripts"
        encryption_config = {
          encryption_type = "KMS"
          key_id          = module.common_aws_kms_key.key_arn
        }
      }
    }
    CONTACT_TRACE_RECORDS = {
      storage_type = "KINESIS_STREAM"
      kinesis_stream_config = {
        stream_arn = module.kinesis.kinesis_stream_arn
      }
    }
    MEDIA_STREAMS = {
      storage_type = "KINESIS_VIDEO_STREAM"

      kinesis_video_stream_config = {
        prefix                 = "kvs"
        retention_period_hours = 24

        encryption_config = {
          encryption_type = "KMS"
          key_id          = try(module.common_aws_kms_key.key_arn)
        }
      }
    }
  }

  lambda_names = {
    case_event_enrichment        = format("%s-lmda-case-event-enrichment-%s-%s", var.company_prefix, local.region_prefix, var.env)
    intake_dialogue_function     = format("%s-lmda-intake-dialogue-function-%s-%s", var.company_prefix, local.region_prefix, var.env)
    get_non_closed_cases         = format("%s-lmda-get-non-closed-cases-%s-%s", var.company_prefix, local.region_prefix, var.env)
    delete_all_cases             = format("%s-lmda-delete-all-cases-%s-%s", var.company_prefix, local.region_prefix, var.env)
    connect_backup               = format("%s-lmda-connect-backup-%s-%s", var.company_prefix, local.region_prefix, var.env)
    sms_backend                  = format("%s-lmda-sms-backend-%s-%s", var.company_prefix, local.region_prefix, var.env)
    ctr_processor                = format("%s-lmda-ctr-processor-%s-%s", var.company_prefix, local.region_prefix, var.env)
    recording_processor          = format("%s-lmda-vm-recording-processor-%s-%s", var.company_prefix, local.region_prefix, var.env)
    transcriber                  = format("%s-lmda-vm-transcriber-%s-%s", var.company_prefix, local.region_prefix, var.env)
    transcribe_error_handler     = format("%s-lmda-vm-transcribe-error-handler-%s-%s", var.company_prefix, local.region_prefix, var.env)
    vm_packager                  = format("%s-lmda-vm-packager-%s-%s", var.company_prefix, local.region_prefix, var.env)
    presigner                    = format("%s-lmda-vm-presigner-%s-%s", var.company_prefix, local.region_prefix, var.env)
    vm_voicemail_timestamper     = format("%s-lmda-vm-voicemail-timestamper-%s-%s", var.company_prefix, local.region_prefix, var.env)
    inbound_sms_tracking         = format("%s-lmda-inbound-sms-tracking-%s-%s", var.company_prefix, local.region_prefix, var.env)
    case_management              = format("%s-lmda-case-management-%s-%s", var.company_prefix, local.region_prefix, var.env)
    set_default_participant_type = format("%s-lmda-set-default-participant-type-%s-%s", var.company_prefix, local.region_prefix, var.env)
    attach_flow_sms_with_case    = format("%s-lmda-attach-flow-sms-with-case-%s-%s", var.company_prefix, local.region_prefix, var.env)
  }

  lambda_arns = {
    for k, v in local.lambda_names : k => "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${v}"
  }

  event_bridge_names = {
    transcriber      = format("%s-evbr-transcriber-%s-%s", var.company_prefix, local.region_prefix, var.env)
    transcribe_error = format("%s-evbr-transcribe-error-%s-%s", var.company_prefix, local.region_prefix, var.env)
    vm_packager      = format("%s-evbr-vm-packager-%s-%s", var.company_prefix, local.region_prefix, var.env)
  }

  event_bridge_rule_arns = {
    for k, v in local.event_bridge_names : k => "arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:rule/${v}-rule"
  }

  lambda_iam_configurations = {
    case_event_enrichment_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.case_event_enrichment_lambda_policy.json]
    },
    intake_dialogue_function_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.intake_dialogue_function_lambda_policy.json]
    },
    get_non_closed_cases_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.get_non_closed_cases_lambda_policy.json]
    },
    delete_all_cases_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.delete_all_cases_lambda_policy.json]
    }
    connect_backup_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.connect_backup_lambda_policy.json]
    }
    sms_backend_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.sms_backend_lambda_policy.json]
    }
    ctr_processor_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.ctr_processor_lambda_policy.json]
    }
    vm_recording_processor_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.vm_recording_processor_lambda_policy.json]
    }

    vm_transcriber_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.vm_transcriber_lambda_policy.json]
    }

    vm_transcribe_error_handler_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.vm_transcribe_error_handler_lambda_policy.json]
    }

    vm_packager_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.vm_packager_lambda_policy.json]
    }

    inbound_sms_tracking_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.inbound_sms_tracking_lambda_policy.json]
    }

    vm_presigner_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.vm_presigner_lambda_policy.json]
    }
    vm_voicemail_timestamper_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.vm_voicemail_timestamper_lambda_policy.json]
    }
    case_management_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.case_management_lambda_policy.json]
    }
    attach_flow_sms_with_case_lambda_policy = {
      number_of_policy_jsons = 1
      policy_jsons           = [data.aws_iam_policy_document.attach_flow_sms_with_case_lambda_policy.json]
    }
  }

  tags = {
    company      = var.company
    env          = var.env
    repository   = var.repo_url
    created_by   = "Terraform"
    project      = var.project
    region       = var.region
    map-migrated = "123456"
  }

  lex_bots_with_lambda_arn = {
    "${var.company_prefix}-lex-intake-bot" = { lex_json_file = "cb-lex-intake-bot-v4.zip", lambda_arn = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.company_prefix}-lmda-intake-dialogue-function-${local.region_prefix}-${var.env}", languages = ["en_US"] }
  }

  # Map field IDs to their options - just add your fields here
  cases_field_options = var.is_primary ? {

    "${try(module.connect_cases_stack[0].outputs["oFieldCallBackAttemptId"], "")}" = [
      { name = "1", value = "1", active = true },
      { name = "2", value = "2", active = true },
      { name = "3", value = "3", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldEthnicityId"], "")}" = [
      { name = "Latinx/Chicanx/Hispanic", value = "Latinx/Chicanx/Hispanic", active = true },
      { name = "non-Latinx/Chicanx/Hispanic", value = "non-Latinx/Chicanx/Hispanic", active = true },
      { name = "Unknown", value = "Unknown", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldGenderId"], "")}" = [
      { name = "Female", value = "Female", active = true },
      { name = "Male", value = "Male", active = true },
      { name = "Nonbinary or Genderqueer", value = "Nonbinary or Genderqueer", active = true },
      { name = "Transgender", value = "Transgender", active = false },
      { name = "Transman", value = "Transman", active = true },
      { name = "Transwoman", value = "Transwoman", active = true },
      { name = "Two Spirit", value = "Two Spirit", active = true },
      { name = "Unknown", value = "Unknown", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldRaceId"], "")}" = [
      { name = "American Indian/Alaska Native", value = "American Indian/Alaska Native", active = true },
      { name = "Another", value = "Another", active = true },
      { name = "Asian-American", value = "Asian-American", active = true },
      { name = "Black/African American", value = "Black/African American", active = true },
      { name = "Middle Eastern/North African", value = "Middle Eastern/North African", active = true },
      { name = "More than one race", value = "More than one race", active = true },
      { name = "Native Hawaiian/Pacific Islander", value = "Native Hawaiian/Pacific Islander", active = true },
      { name = "Unknown", value = "Unknown", active = true },
      { name = "White", value = "White", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldAreYouCallingForYourselfOrSomeoneElseId"], "")}" = [
      { name = "Emergency Services", value = "Emergency Services", active = true },
      { name = "Friend/Family", value = "Friend/Family", active = true },
      { name = "Other", value = "Other", active = true },
      { name = "Person seeking treatment", value = "Self", active = true },
      { name = "Social Worker", value = "Social Worker", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldCallbackRequiredId"], "")}" = [
      { name = "Follow-up Day 1 Attempt 1", value = "Follow-up Day 1 Attempt 1", active = true },
      { name = "Follow-up Day 1 Attempt 2", value = "Follow-up Day 1 Attempt 2", active = true },
      { name = "Follow-up Day 1 Attempt 3", value = "Follow-up Day 1 Attempt 3", active = true },
      { name = "Follow-up Day 30 Attempt 1", value = "Follow-up Day 30 Attempt 1", active = true },
      { name = "Follow-up Day 30 Attempt 2", value = "Follow-up Day 30 Attempt 2", active = true },
      { name = "Follow-up Day 30 Attempt 3", value = "Follow-up Day 30 Attempt 3", active = true },
      { name = "Follow-up Day 60 Attempt 1", value = "Follow-up Day 60 Attempt 1", active = true },
      { name = "Follow-up Day 60 Attempt 2", value = "Follow-up Day 60 Attempt 2", active = true },
      { name = "Follow-up Day 60 Attempt 3", value = "Follow-up Day 60 Attempt 3", active = true },
      { name = "Follow-up Day 90 Attempt 1", value = "Follow-up Day 90 Attempt 1", active = true },
      { name = "Follow-up Day 90 Attempt 2", value = "Follow-up Day 90 Attempt 2", active = true },
      { name = "Follow-up Day 90 Attempt 3", value = "Follow-up Day 90 Attempt 3", active = true },
      { name = "Intake Callback Attempt 2", value = "Intake Callback Attempt 2", active = true },
      { name = "Intake Callback Attempt 3", value = "Intake Callback Attempt 3", active = true },
      { name = "Referral Callback Attempt 1", value = "Referral Callback Attempt 1", active = true },
      { name = "Referral Callback Attempt 2", value = "Referral Callback Attempt 2", active = true },
      { name = "Referral Callback Attempt 3", value = "Referral Callback Attempt 3", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUMATDay1DidYouGoToTheReferralSiteId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUMATDay1DoYouHaveAFollowUpApptScheduledId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUMATDay1WereYouAbleToGetTheTreatmentId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUMATDay30AreYouPlanningToDidYouAttendAFollowUpAppointmentId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUMATDay30AreYouStillTakingMATId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUMATDay60AreYouPlanningToDidYouAttendAFollowUpAppointmentId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUMATDay60AreYouStillTakingMATId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUMATDay90AreYouPlanningToDidYouAttendAFollowUpAppointmentId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUMATDay90AreYouStillTakingMATId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUNonMATAreYouInterestedInAReferralToMATId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFUNonMATDidYouGetWhatYouNeededFromOurCallId"], "")}" = [
      { name = "Yes", value = "Yes", active = true },
      { name = "No", value = "No", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oLatestContactTypeFieldID"], "")}" = [
      { name = "Call", value = "Call", active = true },
      { name = "SMS", value = "SMS", active = true },
      { name = "Voicemail", value = "Voicemail", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldAttemptsId"], "")}" = [
      { name = "1", value = "1", active = true },
      { name = "2", value = "2", active = true },
      { name = "3", value = "3", active = true }
    ]

    "${try(module.connect_cases_stack[0].outputs["oFieldFollowUpDayId"], "")}" = [
      { name = "Follow-up Day 1", value = "1", active = true },
      { name = "Follow-up Day 30", value = "30", active = true },
      { name = "Follow-up Day 60", value = "60", active = true },
      { name = "Follow-up Day 90", value = "90", active = true },
      { name = "Intake Callback", value = "Intake Callback", active = true },
      { name = "Referral Callback", value = "Referral Callback", active = true }
    ]

  } : {}

  # Filter out empty field IDs
  valid_cases_field_options = {
    for field_id, options in local.cases_field_options :
    field_id => options
    if field_id != ""
  }

  system_managed_field_options = var.is_primary ? {
    "Status" = [
      { name = "2- In Progress", value = "In Progress", active = true },
      { name = "2a- Unable to Reach", value = "Unable to Reach", active = true },
      { name = "3- Referral Provided", value = "3- Referral Provided", active = true },
      { name = "3a- Lost to referral", value = "3a- Lost to referral", active = true },
      { name = "4- Follow Up Phase", value = "Follow Up Phase", active = true },
      { name = "4a- Lost to Follow Up", value = "Lost to Follow Up", active = true },
      { name = "5- Opted Out", value = "5- Opted Out", active = true },
      { name = "6- New Voicemail", value = "New Voicemail", active = true },
      { name = "Inbound Referral", value = "Case Manager", active = true },
      { name = "Outbound Referral", value = "MAT Clinic", active = true }
    ]
  } : {}
  # Amazon Connect Cases - System Field IDs (static across all domains/accounts)
  cases_system_fields = {
    customer_id   = "customer_id"
    summary       = "summary"
    assigned_user = "assigned_user"
  }
}

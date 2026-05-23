module "cases_events_to_firehose_event_bridge" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-eventbridge-wrapper?ref=v1.0.0"

  create_bus = false

  company        = var.company
  company_prefix = var.company_prefix
  region_suffix  = local.region_prefix
  environment    = var.env
  name = format(
    "%s-evbr-cases-events-%s-%s",
    var.company_prefix,
    local.region_prefix,
    var.env
  )

  rules = {
    format("%s-evbr-cases-events-%s-%s", var.company_prefix, local.region_prefix, var.env) = {
      description    = "Capture Amazon Connect Cases change events"
      event_bus_name = "default"

      event_pattern = jsonencode({
        source        = ["aws.cases"]
        "detail-type" = ["Amazon Connect Cases Change"]
      })
    }
  }

  targets = {
    (format(
      "%s-evbr-cases-events-%s-%s",
      var.company_prefix,
      local.region_prefix,
      var.env
      )) = [
      {
        name = format(
          "%s-evb-cases-to-fh-target-%s-%s",
          var.company_prefix,
          local.region_prefix,
          var.env
        )
        arn             = module.cases_event_stream_firehose.kinesis_firehose_arn
        attach_role_arn = module.cases_eventbridge_role.iam_role_arn
      }
    ]
  }

  tags = local.tags

  depends_on = [
    module.cases_event_stream_firehose,
    module.cases_eventbridge_role
  ]
}

module "connect_backup_schedule_event_bridge" {
  source         = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-eventbridge-wrapper?ref=v1.0.2"
  company        = var.company
  company_prefix = var.company_prefix
  region_suffix  = local.region_prefix
  environment    = var.env
  create_bus     = false

  schedules = {
    format(
      "%s-evb-connect-backup-schedule-%s-%s",
      var.company_prefix,
      local.region_prefix,
      var.env
      ) = {
      description         = "Schedule to trigger Connect backup Lambda every Monday at 00:00 UTC"
      schedule_expression = "cron(0 0 ? * MON *)" # Every Monday at 00:00 UTC
      timezone            = "UTC"
      arn                 = module.connect_backup_lambda.lambda_function_arn
      role_arn            = module.connect_backup_eventbridge_scheduler_role.iam_role_arn
    }
  }

  tags = local.tags

  depends_on = [
    module.connect_backup_lambda,
    module.connect_backup_eventbridge_scheduler_role
  ]
}

module "vm_transcribe_error_handler_event_bridge" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-eventbridge-wrapper?ref=v1.0.11"

  create_bus = false

  company        = var.company
  company_prefix = var.company_prefix
  region_suffix  = local.region_prefix
  environment    = var.env
  name = local.event_bridge_names.transcribe_error

  create = {
    role = false
  }

  rules = {
    (local.event_bridge_names.transcribe_error) = {
      description    = "Capture Amazon Transcribe Job State Change events for VMX3"
      event_bus_name = "default"

      event_pattern = jsonencode({
        "detail-type" = ["Transcribe Job State Change"]
        source        = ["aws.transcribe"]
        detail = {
          TranscriptionJobName   = [{ prefix = "vmx3_" }]
          TranscriptionJobStatus = ["FAILED"]
        }
      })
    }
  }

  targets = {
    (local.event_bridge_names.transcribe_error) = [
      {
        name = format("%s-evb-transcribe-error-target-%s-%s", var.company_prefix, local.region_prefix, var.env)
        arn  = local.lambda_arns.transcribe_error_handler
      }
    ]
  }

  tags = local.tags
}


module "vm_packager_event_bridge" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-eventbridge-wrapper?ref=v1.0.11"

  create_bus = false

  company        = var.company
  company_prefix = var.company_prefix
  region_suffix  = local.region_prefix
  environment    = var.env
  name = local.event_bridge_names.vm_packager

  create = {
    role = false
  }

  rules = {
    (local.event_bridge_names.vm_packager) = {
      description    = "Trigger VM Packager on S3 object creation"
      event_bus_name = "default"

      event_pattern = jsonencode({
        "detail-type" = ["Object Created"]
        source        = ["aws.s3"]
        detail = {
          bucket = {
            name = [module.s3_voicemail_transcription.bucket_id]
          }
        }
      })
    }
  }

  targets = {
    (local.event_bridge_names.vm_packager) = [
      {
        name = format("%s-evb-vm-packager-target-%s-%s", var.company_prefix, local.region_prefix, var.env)
        arn  = local.lambda_arns.vm_packager
      }
    ]
  }

  tags = local.tags

  depends_on = [
    module.s3_voicemail_transcription
  ]
}

module "vm_transcriber_event_bridge" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-eventbridge-wrapper?ref=v1.0.11"

  create_bus = false

  company        = var.company
  company_prefix = var.company_prefix
  region_suffix  = local.region_prefix
  environment    = var.env
  name = local.event_bridge_names.transcriber
  create = {
    role = false
  }

  rules = {
    (local.event_bridge_names.transcriber) = {
      description    = "Trigger Transcriber on S3 object creation in recording bucket"
      event_bus_name = "default"

      event_pattern = jsonencode({
        "detail-type" = ["Object Created"]
        source        = ["aws.s3"]
        detail = {
          bucket = {
            name = [module.s3_voicemail_recording.bucket_id]
          }
        }
      })
    }
  }

  targets = {
    (local.event_bridge_names.transcriber) = [
      {
        name = format("%s-evb-transcriber-target-%s-%s", var.company_prefix, local.region_prefix, var.env)
        arn  = local.lambda_arns.transcriber
      }
    ]
  }

  tags = local.tags

  depends_on = [
    module.s3_voicemail_recording
  ]
}




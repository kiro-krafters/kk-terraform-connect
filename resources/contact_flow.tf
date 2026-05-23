locals {
  sms_contact_flows = {
    "cb_outbound_flow" = {
      content = templatefile(
        "${path.module}/contact_flows/cb_outbound_flow.json",
        {}
      )
      type        = "OUTBOUND_WHISPER"
      description = "Outbound whisper flow for Bridge Connect."
      tags        = local.tags
    }

    "cb_sms_inbound_flow" = {
      content = templatefile(
        "${path.module}/contact_flows/cb-sms-flow-v1.json.tftpl",
        {
          intake_bot_alias_arn            = module.lex_bot["cb-lex-intake-bot"].bot_alias_arn
          get_non_closed_cases_lambda_arn = module.get_non_closed_cases_lambda.lambda_function_arn
          inbound_sms_tracking_lambda_arn = module.inbound_sms_tracking.lambda_function_arn
          connect_instance_id             = local.connect_instance_id
          general_support_template_id     = module.connect_cases_stack[0].outputs["oGeneralSupportTemplateId"]
          #field_zip_code_id               = module.connect_cases_stack[0].outputs["oFieldZIPCodeId"]
          field_sms_consent_id         = module.connect_cases_stack[0].outputs["oFieldSMSConsentId"]
          latest_contact_type_field_id = module.connect_cases_stack[0].outputs["oLatestContactTypeFieldID"]
          cb_masking_flow_module_id    = module.amazon_connect_associations[0].contact_flow_modules["cb_apply_masking_module"].contact_flow_module_id

        }
      )
      type        = "CONTACT_FLOW"
      description = "SMS inbound flow for Bridge Connect."
      tags        = local.tags
    }
    "cb_phone_agent_whisper_flow" = {
      content = templatefile(
        "${path.module}/contact_flows/cb-phone-agent-whisper-flow.json",
        {}
      )
      type        = "AGENT_WHISPER"
      description = "Phone agent whisper flow for Bridge Connect."
      tags        = local.tags
    }
    "cb_phone_inbound_customer_queue_flow" = {
      content = templatefile(
        "${path.module}/contact_flows/cb-phone-inbound-customer-queue-flow.json.tftpl",
        {
          inbound_call_connecting_to_navigator_prompt_arn    = data.aws_connect_prompt.inbound_call_connecting_to_navigator_prompt.arn
          inbound_call_navigator_busy_prompt_arn             = data.aws_connect_prompt.inbound_call_navigator_busy_prompt.arn
          music_pop_throw_yourself_in_front_of_it_prompt_arn = data.aws_connect_prompt.music_pop_throw_yourself_in_front_of_it_prompt.arn
          silence_prompt_arn                                 = data.aws_connect_prompt.silence_prompt.arn
          beep_prompt_arn                                    = data.aws_connect_prompt.beep_prompt.arn
          cb_vm_timestamper_lambda_arn                       = module.vm_voicemail_timestamper_lambda.lambda_function_arn
        }
      )
      type        = "CUSTOMER_QUEUE"
      description = "Phone inbound customer queue flow for Bridge Connect."
      tags        = local.tags
    }
  }
  voice_contact_flows = {
    "cb_inbound_phone_call_flow" = {
      content = templatefile(
        "${path.module}/contact_flows/cb-inbound-voice-flow-v1.json.tftpl",
        {
          cb_holiday_hoo_arn                       = module.amazon_connect_associations[0].hours_of_operations["cb_holiday"].arn
          cb_business_hoo_arn                      = module.amazon_connect_associations[0].hours_of_operations["cb_business_hours"].arn
          cb_phone_inbound_customer_queue_flow_arn = module.amazon_connect_associations[0].contact_flows["cb_phone_inbound_customer_queue_flow"].arn
          cb_phone_agent_whisper_flow_arn          = module.amazon_connect_associations[0].contact_flows["cb_phone_agent_whisper_flow"].arn
          off_for_holidays_prompt_arn              = data.aws_connect_prompt.off_for_holidays_prompt.arn
          out_of_hours_prompt_arn                  = data.aws_connect_prompt.out_of_hours_prompt.arn
          beep_prompt_arn                          = data.aws_connect_prompt.beep_prompt.arn
          silence_prompt_arn                       = data.aws_connect_prompt.silence_prompt.arn
          get_non_closed_cases_lambda_arn          = module.get_non_closed_cases_lambda.lambda_function_arn
          cb_agent_transfer_queue_arn              = module.amazon_connect_associations[0].queues["cb_agent_queue"].arn
          cb_tasks_queue_arn                       = module.amazon_connect_associations[0].queues["cb_task_queue"].arn
          general_support_template_id              = module.connect_cases_stack[0].outputs["oGeneralSupportTemplateId"]
          cb_masking_flow_module_id                = module.amazon_connect_associations[0].contact_flow_modules["cb_apply_masking_module"].contact_flow_module_id
          cb_main_voicemail_module_id              = module.amazon_connect_associations[0].contact_flow_modules["cb_main_voicemail_module"].contact_flow_module_id
          latest_contact_type_field_id             = module.connect_cases_stack[0].outputs["oLatestContactTypeFieldID"]
        }
      )
      type        = "CONTACT_FLOW"
      description = "Inbound phone call flow for Bridge Connect."
      tags        = local.tags
    }

    "cb_task_flow" = {
      content = templatefile(
        "${path.module}/contact_flows/cb-task-flow.json.tftpl",
        {
          cb_task_queue = module.amazon_connect_associations[0].queues["cb_task_queue"].arn
        }
      )
      type        = "AGENT_TRANSFER"
      description = "Task flow for transferring tasks to the callback queue in Bridge Connect."
      tags        = local.tags
    }

  }
}

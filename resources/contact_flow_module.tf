locals {
  contact_flow_modules = {
    "cb_apply_masking_module" = {
      content = templatefile(
        "${path.module}/contact_flow_modules/cb_apply_masking_module.json.tftpl",
        {
          cb_flow_config_data_table_id = element(
            split("/", module.data_table_stack[0].outputs["oCBFlowConfigDataTableArn"]),
            3
          )

        }
      )
      description = "Masking Module for CB - Masks sensitive data in contact attributes"
    }

    "cb_main_voicemail_module" = {
      content = templatefile(
        "${path.module}/contact_flow_modules/cb_main_voicemail_module.json.tftpl",
        {
          cb_tasks_queue_arn           = module.amazon_connect_associations[0].queues["cb_task_queue"].arn
          cb_vm_timestamper_lambda_arn = module.vm_voicemail_timestamper_lambda.lambda_function_arn
          beep_prompt_arn              = data.aws_connect_prompt.beep_prompt.arn
        }
      )
      description = "Voice Mail Module for CB"
    }
  }
}

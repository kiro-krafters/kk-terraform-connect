locals {
  queues = {
    "cb_agent_queue" = {
      description           = "A simple agent voice queue for Bridge Connect"
      hours_of_operation_id = try(module.amazon_connect_associations[0].hours_of_operations["cb_business_hours"].hours_of_operation_id, "")
      status                = "ENABLED"
      quick_connect_ids     = []
      outbound_caller_config = {
        outbound_caller_id_name      = "CA Bridge Connect"
        outbound_flow_id             = data.aws_connect_contact_flow.cb_outbound_flow.arn
        # outbound_flow_id             = data.aws_connect_contact_flow.default_outbound_flow.arn
        outbound_caller_id_number_id = var.outbound_caller_id_number_id
      }
      tags = local.tags
    }
    "cb_task_queue" = {
      description           = "A simple task queue for callback tasks in CA Bridge Connect"
      hours_of_operation_id = try(data.aws_connect_hours_of_operation.cb_basic_hours.hours_of_operation_id, "")
      status                = "ENABLED"
      quick_connect_ids     = []
      tags                  = local.tags
    }
  }
}

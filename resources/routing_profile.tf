locals {
  routing_profiles = {
    "cb_agent_routing_profile" = {
      description               = "Routing profile for Bridge Connect agents"
      default_outbound_queue_id = try(module.amazon_connect_associations[0].queues["cb_agent_queue"].queue_id, "")

      media_concurrencies = [
        {
          channel     = "VOICE"
          concurrency = 1
        },
        {
          channel     = "CHAT"
          concurrency = 2
        },
        {
          channel     = "TASK"
          concurrency = 6
        }
      ]

      queue_configs = [
        {
          channel  = "VOICE"
          delay    = 0
          priority = 1
          queue_id = try(module.amazon_connect_associations[0].queues["cb_agent_queue"].queue_id, "")
        },
        {
          channel  = "CHAT"
          delay    = 0
          priority = 1
          queue_id = try(module.amazon_connect_associations[0].queues["cb_agent_queue"].queue_id, "")
        },
        {
          channel  = "TASK"
          delay    = 0
          priority = 1
          queue_id = try(module.amazon_connect_associations[0].queues["cb_agent_queue"].queue_id, "")
        },
        {
          channel  = "TASK"
          delay    = 0
          priority = 2
          queue_id = try(module.amazon_connect_associations[0].queues["cb_task_queue"].queue_id, "")
        }
      ]
      tags = local.tags
    }
  }
}

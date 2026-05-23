resource "awscc_connect_task_template" "ca_bridge_task_template" {
  instance_arn = "arn:aws:connect:${var.region}:${var.account_number}:instance/${local.connect_instance_id}"
  name         = "cb_call_back"
  description  = "Task template for managing callback tasks in Amazon Connect"
  status       = "ACTIVE"

  self_assign_contact_flow_arn = try(module.amazon_connect_voice_flow[0].contact_flows["cb_task_flow"].arn, "")

  fields = [
    {
      id = {
        name = "Task name"
      }
      type        = "NAME"
      description = "The name of the task"
    },
    {
      id = {
        name = "Description"
      }
      type        = "DESCRIPTION"
      description = "The description of the task"
    },
    {
      id = {
        name = "Type of Callback"
      }
      description = "The queue to assign the task to"
      type        = "SINGLE_SELECT"
      single_select_options = [
        "New intake callback attempt 2",
        "New intake callback attempt 3",
        "Referral callback attempt 1",
        "Referral callback attempt 2",
        "Referral callback attempt 3",
      ]
    },
    {
      id = {
        name = "Assign to"
      }
      type        = "QUICK_CONNECT"
      description = "The queue to assign the task to"
    },
    {
      id = {
        name = "Self assign"
      }
      type        = "SELF_ASSIGN"
      description = "Whether agents can self assign tasks using this template"
    },
    {
      id = {
        name = "Schedule"
      }
      type        = "SCHEDULED_TIME"
      description = "The scheduled time to complete the task"
    }
  ]

  # Set default values
  defaults = [
    {
      id = {
        name = "Self assign"
      }
      default_value = "false"
    }
  ]


  # Set constraints 
  constraints = {
    required_fields = [
      {
        id = {
          name = "Task name"
        }
      }
    ]
  }

  tags = [
    {
      key   = "Type"
      value = "Simple"
    }
  ]
}

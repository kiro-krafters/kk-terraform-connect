locals {
  hours_of_operations = {
    cb_holiday = {
      description = "Hours of operation for holiday schedule"
      time_zone   = "America/Los_Angeles"

      config = [
        {
          day        = "SUNDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "MONDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "TUESDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "WEDNESDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "THURSDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "FRIDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "SATURDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        }
      ]

      tags = local.tags
    }

    cb_business_hours = {
      description = "Standard business hours Monday-Friday 9AM–5PM"
      time_zone   = "America/Los_Angeles"

      config = [
        {
          day        = "MONDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "TUESDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "WEDNESDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "THURSDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        },
        {
          day        = "FRIDAY"
          start_time = { hours = 9, minutes = 0 }
          end_time   = { hours = 17, minutes = 0 }
        }
      ]

      tags = local.tags
    }

    cb_24_7_hours = {
      description = "24/7 Hours of Operation"
      time_zone   = "America/Los_Angeles"

      config = [
        {
          day        = "SUNDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "MONDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "TUESDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "WEDNESDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "THURSDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "FRIDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        },
        {
          day        = "SATURDAY"
          start_time = { hours = 0, minutes = 0 }
          end_time   = { hours = 23, minutes = 59 }
        }
      ]

      tags = local.tags
    }
  }

}

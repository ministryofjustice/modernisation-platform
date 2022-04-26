resource "pagerduty_escalation_policy" "on_call" {
  name  = "Modernisation Platform On Call Policy"
  teams = [pagerduty_team.modernisation_platform.id]
  # num_loops = 9

  rule {
    escalation_delay_in_minutes = 10
    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.primary.id
    }
  }
  # Comment out until we have a proper on call rota
  # rule {
  #   escalation_delay_in_minutes = 10
  #   target {
  #     type = "schedule_reference"
  #     id   = pagerduty_schedule.secondary.id
  #   }
  # }
}

resource "pagerduty_escalation_policy" "low_priority" {
  name  = "Modernisation Platform Low Priority Policy"
  teams = [pagerduty_team.modernisation_platform.id]

  rule {
    escalation_delay_in_minutes = 10
    target {
      type = "user_reference"
      id   = pagerduty_user.pager_duty_users["david_elliott"].id
      #id   = pagerduty_user.platforms.id
    }
  }
}

resource "pagerduty_schedule" "primary" {
  name      = "Modernisation Platform (primary)"
  time_zone = "Europe/London"

  layer {
    name                         = "Primary Schedule"
    start                        = "2021-12-06T10:00:00Z"
    rotation_virtual_start       = "2021-12-06T10:00:00Z"
    rotation_turn_length_seconds = 604800
    users                        = local.oncall_users
  }

  teams = [pagerduty_team.modernisation_platform.id]
}

resource "pagerduty_schedule" "secondary" {
  name      = "Modernisation Platform (secondary)"
  time_zone = "Europe/London"

  layer {
    name                         = "Secondary Schedule"
    start                        = "2021-12-13T10:00:00Z"
    rotation_virtual_start       = "2021-12-13T10:00:00Z"
    rotation_turn_length_seconds = 604800
    users                        = local.oncall_users
  }

  teams = [pagerduty_team.modernisation_platform.id]
}

resource "pagerduty_escalation_policy" "on_call" {
  name      = "Modernisation Platform On Call Policy"
  teams     = [pagerduty_team.modernisation_platform.id]
  num_loops = 9

  rule {
    escalation_delay_in_minutes = 20
    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.primary.id
    }
  }
  rule {
    escalation_delay_in_minutes = 10
    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.secondary.id
    }
  }
}

resource "pagerduty_escalation_policy" "low_priority" {
  name  = "Modernisation Platform Low Priority Policy"
  teams = [pagerduty_team.modernisation_platform.id]

  rule {
    escalation_delay_in_minutes = 10
    target {
      type = "user_reference"
      id   = pagerduty_user.pager_duty_users["modernisation_platform"].id
    }
  }
}

resource "pagerduty_escalation_policy" "member_policy" {
  name  = "Modernisation Platform Member Policy"
  teams = [pagerduty_team.modernisation_platform_members.id]

  rule {
    escalation_delay_in_minutes = 10
    target {
      type = "user_reference"
      id   = pagerduty_user.pager_duty_users["modernisation_platform"].id
    }
  }
}

resource "pagerduty_schedule" "primary" {
  name      = "Modernisation Platform (primary)"
  time_zone = "Europe/London"

  # Incidents will not be created if there is no one on call. Adding a fall back layer to ensure there is always a user on call.
  layer {
    name                         = "Fallback layer"
    start                        = "2021-07-25T06:00:00Z"
    rotation_virtual_start       = "2021-07-25T06:00:00Z"
    rotation_turn_length_seconds = 604800
    users                        = [pagerduty_user.pager_duty_users["modernisation_platform"].id]
  }

  layer {
    name                         = "Primary Schedule"
    start                        = "2022-07-25T06:00:00Z"
    rotation_virtual_start       = "2022-07-25T06:00:00Z"
    rotation_turn_length_seconds = 604800
    users = [
      local.david_sibley,
      local.david_elliott,
      local.richard_green,
      local.edward_proctor,
      local.ewa_stempel,
      local.mark_roberts,
      local.aaron_robinson
    ]
  }

  teams = [pagerduty_team.modernisation_platform.id]
}

resource "pagerduty_schedule" "secondary" {
  name      = "Modernisation Platform (secondary)"
  time_zone = "Europe/London"

  layer {
    name                         = "Fallback layer"
    start                        = "2021-07-25T06:00:00Z"
    rotation_virtual_start       = "2021-07-25T06:00:00Z"
    rotation_turn_length_seconds = 604800
    users                        = [pagerduty_user.pager_duty_users["modernisation_platform"].id]
  }
  layer {
    name                         = "Secondary Schedule"
    start                        = "2022-07-25T06:00:00Z"
    rotation_virtual_start       = "2022-07-25T06:00:00Z"
    rotation_turn_length_seconds = 604800
    users = [
      local.david_elliott,
      local.richard_green,
      local.david_sibley,
      local.ewa_stempel,
      local.edward_proctor,
      local.aaron_robinson,
      local.mark_roberts
    ]
  }

  teams = [pagerduty_team.modernisation_platform.id]
}

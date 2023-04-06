#teams
resource "pagerduty_team" "modernisation_platform" {
  name = "Modernisation Platform"
}

resource "pagerduty_team" "modernisation_platform_members" {
  name = "Modernisation Platform Members"
}

resource "pagerduty_team_membership" "modernisation_platform_membership" {
  for_each = local.modernisation_platform_users
  team_id  = pagerduty_team.modernisation_platform.id
  user_id  = each.value.id
}

#users
resource "pagerduty_user" "pager_duty_users" {
  for_each = local.pager_duty_users
  name     = each.value.name
  email    = each.value.email
  lifecycle {
    ignore_changes = [
      # Ignore changes to job_title, e.g. because user are
      # able to update this inside Pagerduty and it might change (We also don't care what it is).
      job_title,
    ]
  }
}

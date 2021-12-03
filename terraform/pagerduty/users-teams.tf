#teams
resource "pagerduty_team" "modernisation_platform" {
  name = "Modernisation Platform"
}

resource "pagerduty_team_membership" "modernisation_platform_membership" {
  for_each = pagerduty_user.modernisation_platform_users
  team_id  = pagerduty_team.modernisation_platform.id
  user_id  = each.value.id
}

resource "pagerduty_team_membership" "modernisation_platform_membership_existing_users" {
  for_each = toset(local.existing_users)
  team_id  = pagerduty_team.modernisation_platform.id
  user_id  = each.key
}

#users
resource "pagerduty_user" "modernisation_platform_users" {
  for_each = { for k, v in local.modernisation_platform_team_members : k => v }
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

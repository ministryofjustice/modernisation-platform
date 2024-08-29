# This file is to set up pager duty if you want to test it or if it is required. Ucomment the lines below if it is needed

resource "pagerduty_team" "sprinkler" {
  name        = "sprinkler"
  description = "sprinkler"
}

resource "pagerduty_user" "sprinkler-user" {
  name  = "A Name"
  email = "SomeAddress.name"
  teams = [pagerduty_team.sprinkler.id]
}

resource "pagerduty_escalation_policy" "member_policy" {
  name      = "member_policy" 
  rule {
    escalation_delay_in_minutes = 5
  target {
      type = "user_reference"
      id   = pagerduty_user.sprinkler-user.id
    }
  }
}

resource "pagerduty_service" "sprinkler-development" {
  name                    = "sptinkler-development"
  description             = "sprinkler-development"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "sprinkler-integration" {
  #name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.sprinkler-development.id
  #vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "sprinkler_connection" {
  source_id         = pagerduty_service.sprinkler-development.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C04QGQML68P"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
  config {
    events = [
      "incident.resolved"
    ]
    priorities = ["*"]
  }
}
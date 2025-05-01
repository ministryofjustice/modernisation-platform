
# Note slack integrations for the service to the relevant channels must be done manually in pagerduty and slack
# New pagerduty_service resources being added require the use of a "pagerduty_slack_connection" resource to add that integration.

### Core platform security hub, config and cloudtrail alerts
resource "pagerduty_service" "core_alerts" {
  name                    = "Core Alerts - Modernisation Platform"
  description             = "Core Infrastructure Alerts"
  auto_resolve_timeout    = 14400
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.low_priority.id
  alert_creation          = "create_alerts_and_incidents"
  incident_urgency_rule {
    type    = "constant"
    urgency = "low"
  }
}

resource "pagerduty_service_integration" "core_alerts_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.core_alerts.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

### High Priority Alerts for where the on-call incident process is not required
resource "pagerduty_service" "core_alerts_high_priority" {
  name                    = "High Priority Alerts - Modernisation Platform"
  description             = "High Priority Alerts"
  auto_resolve_timeout    = 14400
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.high_priority.id
  alert_creation          = "create_alerts_and_incidents"
  incident_urgency_rule {
    type    = "constant"
    urgency = "high"
  }
}

resource "pagerduty_service_integration" "core_alerts_high_priority_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.core_alerts_high_priority.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "core_alerts_high_priority" {
  source_id         = pagerduty_service.core_alerts_high_priority.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C03CY6451QT" # Slack channel: #modernisation-platform-high-priority-alarms
  notification_type = "responder"
  config {
    events = [
      "incident.triggered",
      "incident.acknowledged",
      "incident.escalated",
      "incident.resolved",
      "incident.reassigned",
      "incident.annotated",
      "incident.unacknowledged",
      "incident.delegated",
      "incident.priority_updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}


resource "pagerduty_service" "security_hub" {
  name                    = "Security Hub Alerts - Modernisation Platform"
  description             = "Security Hub Alerts"
  auto_resolve_timeout    = 14400
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.low_priority.id
  alert_creation          = "create_alerts_and_incidents"
  incident_urgency_rule {
    type    = "constant"
    urgency = "low"
  }
}

resource "pagerduty_service_integration" "security_hub" {
  name    = data.pagerduty_vendor.security_hub.name
  service = pagerduty_service.security_hub.id
  vendor  = data.pagerduty_vendor.security_hub.id
}

resource "pagerduty_slack_connection" "security_hub" {
  source_id         = pagerduty_service.security_hub.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C07SNBJBVC6" # Slack channel: #modernisation-platform-security-hub-alerts
  notification_type = "responder"
  config {
    events = [
      "incident.triggered",
      "incident.acknowledged",
      "incident.escalated",
      "incident.resolved",
      "incident.reassigned",
      "incident.annotated",
      "incident.unacknowledged",
      "incident.delegated",
      "incident.priority_updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}

resource "pagerduty_service" "security_hub_members" {
  name                    = "Security Hub Alerts - Modernisation Platform Member Accounts"
  description             = "Security Hub Alerts - Member Accounts"
  auto_resolve_timeout    = 14400
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.low_priority.id
  alert_creation          = "create_alerts_and_incidents"
  incident_urgency_rule {
    type    = "constant"
    urgency = "low"
  }
}

resource "pagerduty_service_integration" "security_hub_members" {
  name    = data.pagerduty_vendor.security_hub.name
  service = pagerduty_service.security_hub_members.id
  vendor  = data.pagerduty_vendor.security_hub.id
}

resource "pagerduty_slack_connection" "security_hub_members" {
  source_id         = pagerduty_service.security_hub_members.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C08GRKZ1W4F" # Slack channel: #modernisation-platform-members-security-hub-alerts
  notification_type = "responder"
  config {
    events = [
      "incident.triggered",
      "incident.acknowledged",
      "incident.escalated",
      "incident.resolved",
      "incident.reassigned",
      "incident.annotated",
      "incident.unacknowledged",
      "incident.delegated",
      "incident.priority_updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}


resource "pagerduty_service_event_rule" "mfa-console-access" {
  service  = pagerduty_service.core_alerts.id
  position = 0
  disabled = "false"

  conditions {
    operator = "and"
    subconditions {
      operator = "contains"
      parameter {
        value = "sign-in-without-mfa"
        path  = "summary"
      }
    }
  }

  actions {
    severity {
      value = "info"
    }
    annotate {
      value = "Suppressed as triggered by SSO sign on"
    }

    suppress {
      value = true
    }
  }
}

# contact-on-call-modernisation-platform email
# note email integration must be configured manually in PagerDuty
resource "pagerduty_service" "contact_on_call" {
  name                    = "Contact On Call Email Address -  Modernisation Platform"
  description             = "Emails received to the on call email address"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.on_call.id
  alert_creation          = "create_alerts_and_incidents"
  incident_urgency_rule {
    type    = "constant"
    urgency = "high"
  }
}

resource "pagerduty_service" "ddos" {
  name                    = "DDOS Protection - Modernisation Platform"
  description             = "Member DDOS Protection"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.on_call.id
  alert_creation          = "create_alerts_and_incidents"
  incident_urgency_rule {
    type    = "constant"
    urgency = "high"
  }
}

resource "pagerduty_service_integration" "ddos_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.ddos.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_service" "tgw" {
  name                    = "Transit Gateway - Modernisation Platform"
  description             = "Transit Gateway"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.on_call.id
  alert_creation          = "create_alerts_and_incidents"
  incident_urgency_rule {
    type    = "constant"
    urgency = "high"
  }
}

resource "pagerduty_service_integration" "tgw_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.tgw.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_service" "networking" {
  name                    = "Networking - Modernisation Platform"
  description             = "Generic service to raise networking issues against"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.on_call.id
  alert_creation          = "create_alerts_and_incidents"
  incident_urgency_rule {
    type    = "constant"
    urgency = "high"
  }
}

resource "pagerduty_service_integration" "networking_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.networking.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_service" "operations" {
  name                    = "Operations - Modernisation Platform"
  description             = "Generic service to raise operations issues against"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.on_call.id
  alert_creation          = "create_alerts_and_incidents"
  incident_urgency_rule {
    type    = "constant"
    urgency = "high"
  }
}

resource "pagerduty_service_integration" "operations_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.operations.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_service" "security" {
  name                    = "Security - Modernisation Platform"
  description             = "Generic service to raise security issues against"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.on_call.id
  alert_creation          = "create_alerts_and_incidents"
  incident_urgency_rule {
    type    = "constant"
    urgency = "high"
  }
}

resource "pagerduty_service_integration" "security_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.security.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

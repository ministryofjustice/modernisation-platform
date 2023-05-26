
# Note slack integrations for the service to the relevant channels must be done manually in pagerduty and slack

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

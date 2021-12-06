
# Note slack integrations for the service to the relevant channels must be done manually in pagerduty and slack
resource "pagerduty_service" "core_alerts" {
  name                    = "Modernisation Platform Core Alerts"
  description             = "Modernisation Platform Core Infrastructure Alerts"
  auto_resolve_timeout    = 14400
  acknowledgement_timeout = 7200
  escalation_policy       = pagerduty_escalation_policy.default.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.core_alerts.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

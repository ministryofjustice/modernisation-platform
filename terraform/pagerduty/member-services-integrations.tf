# Member services for SNS -> Slack integration

# # Copy and uncomment the following code
# resource "pagerduty_service" "my_application" {
#   name                    = "My Application Alarms"
#   description             = "My Application Alarms"
#   auto_resolve_timeout    = 345600
#   acknowledgement_timeout = null
#   escalation_policy       = pagerduty_escalation_policy.member_policy.id
#   alert_creation          = "create_alerts_and_incidents"
# }

# resource "pagerduty_service_integration" "my_application_cloudwatch" {
#   name    = data.pagerduty_vendor.cloudwatch.name
#   service = pagerduty_service.my_application.id
#   vendor  = data.pagerduty_vendor.cloudwatch.id
# }

# # Slack channel: #my-application-alarm-slack-channel

# Nomis
resource "pagerduty_service" "nomis" {
  name                    = "Nomis Alarms"
  description             = "Nomis Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = null
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "nomis_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.nomis.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# Slack channel: #dso_alerts_modernisation_platform

# LAA OAS
resource "pagerduty_service" "laa_oas" {
  name                    = "Legal Aid Agency OAS Application"
  description             = "Legal Aid Agency OAS Application Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = null
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_oas_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_oas.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# # Slack channel: #laa-obiee-alerts-nonprod TBC

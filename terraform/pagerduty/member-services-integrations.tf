# Member services for SNS -> Slack integration

# # Copy and uncomment the following code
# resource "pagerduty_service" "my_application" {
#   name                    = "My Application Alarms"
#   description             = "My Application Alarms"
#   auto_resolve_timeout    = 345600
#   acknowledgement_timeout = "null"
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
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "nomis_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.nomis.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# Slack channel: #dso_alerts_modernisation_platform

# Nomis Non Prod

resource "pagerduty_service" "nomis_nonprod" {
  name                    = "Nomis Alarms Non Prod"
  description             = "Nomis Alarms Non Prod"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "nomis_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.nomis_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# Slack channel: #dso_alerts_devtest_modernisation_platform

# LAA MLRA Non Prod
resource "pagerduty_service" "laa_mlra_nonprod" {
  name                    = "Legal Aid Agency MLRA Application Non Prod"
  description             = "Legal Aid Agency MLRA Application Non Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_mlra_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_mlra_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# # Slack channel: # TBC

# LAA MLRA Prod
resource "pagerduty_service" "laa_mlra_prod" {
  name                    = "Legal Aid Agency MLRA Application Production"
  description             = "Legal Aid Agency MLRA Application Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_mlra_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_mlra_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# # Slack channel: # TBC

# LAA OAS - Non Prod
resource "pagerduty_service" "laa_oas_nonprod" {
  name                    = "Legal Aid Agency OAS Application Non Prod"
  description             = "Legal Aid Agency OAS Application Non Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_oas_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_oas_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# # Slack channel: #laa-obiee-alerts-nonprod TBC

# LAA OAS - Prod
resource "pagerduty_service" "laa_oas_prod" {
  name                    = "Legal Aid Agency OAS Application Production"
  description             = "Legal Aid Agency OAS Application Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_oas_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_oas_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# # Slack channel: #laa-obiee-alerts-prod TBC


# Delius Jitbit - Non Prod

resource "pagerduty_service" "jitbit_nonprod" {
  name                    = "Delius Jitbit Non Prod"
  description             = "Delius Jitbit Non Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "jitbit_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.jitbit_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# # Slack channel: # TBC

resource "pagerduty_service" "iaps_nonprod" {
  name                    = "Delius IAPS Non Prod"
  description             = "Delius IAPS Non Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "iaps_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.iaps_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# Slack channel: # TBC

# LAA MojFin - Prod
resource "pagerduty_service" "laa_mojfin_prod" {
  name                    = "Legal Aid Agency MojFin Application Production"
  description             = "Legal Aid Agency MojFin Application Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_mojfin_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_mojfin_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# # Slack channel: #laa-obiee-alerts-prod TBC

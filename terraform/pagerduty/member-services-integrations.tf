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

# OASys
resource "pagerduty_service" "oasys" {
  name                    = "OASys Alarms"
  description             = "OASys Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "oasys_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.oasys.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# Slack channel: #dso_alerts_modernisation_platform

# OASys Non Prod

resource "pagerduty_service" "oasys_nonprod" {
  name                    = "OASys Alarms Non Prod"
  description             = "OASys Alarms Non Prod"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "oasys_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.oasys_nonprod.id
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

# # Slack channel: # laa-alerts-mlra-non-prod

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

# # Slack channel: # laa-alerts-mlra-prod

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

# # Slack channel: #laa-obiee-alerts-nonprod

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

# # Slack channel: #laa-obiee-alerts-prod


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

# # Slack channel: #laa-alerts-mojfin-prod

# NOTE: Update escalation_policy once alarms have been tested
resource "pagerduty_service" "hmpps_shef_dba_high_priority" {
  name                    = "HMPPS Sheffield DBA High Priority Alarms"
  description             = "Production alarms requiring immediate attention by Sheffield DBAs, i.e. worthy of overnight callout"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}
resource "pagerduty_service_integration" "hmpps_shef_dba_high_priority" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.hmpps_shef_dba_high_priority.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}
# Slack channel: dba_alerts_prod

resource "pagerduty_service" "hmpps_shef_dba_low_priority" {
  name                    = "HMPPS Sheffield DBA Low Priority Alarms"
  description             = "Low priority production alarms for attention of Sheffield DBAs"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}
resource "pagerduty_service_integration" "hmpps_shef_dba_low_priority" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.hmpps_shef_dba_low_priority.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}
# Slack channel: dba_alerts_prod

resource "pagerduty_service" "hmpps_shef_dba_non_prod" {
  name                    = "HMPPS Sheffield DBA Non-Production Alarms"
  description             = "Non-production alarms for attention of Sheffield DBAs"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}
resource "pagerduty_service_integration" "hmpps_shef_dba_non_prod" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.hmpps_shef_dba_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}
# Slack channel: dba_alerts_devtest

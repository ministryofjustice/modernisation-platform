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

# resource "pagerduty_slack_connection" "my_connection" {
#   source_id = pagerduty_service.my_application.id
#   source_type = "service_reference"
#   workspace_id = local.slack_workspace_id
#   channel_id = "C02PFCG8M1R"  <--- Slack channel ID for the slack channel you what pagerduty to use
#   notification_type = "responder"
#   config {
#     events = [
#       "incident.triggered",
#       "incident.acknowledged",
#       "incident.escalated",
#       "incident.resolved",
#       "incident.reassigned",
#       "incident.annotated",
#       "incident.unacknowledged",
#       "incident.delegated",
#       "incident.priority_updated",
#       "incident.responder.added",
#       "incident.responder.replied",
#       "incident.action_invocation.created",
#       "incident.action_invocation.terminated",
#       "incident.action_invocation.updated",
#       "incident.status_update_published",
#       "incident.reopened"
#     ]
#     priorities = ["*"]
#   }
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

resource "pagerduty_slack_connection" "nomis_connection" {
  source_id         = pagerduty_service.nomis.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C04E4FM3KS7"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]

    priorities = ["*"]
  }
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

resource "pagerduty_slack_connection" "nomis_nonprod_connection" {
  source_id         = pagerduty_service.nomis_nonprod.id
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
      "incident.triggered",
      "incident.acknowledged",
      "incident.escalated",
      "incident.resolved",
      "incident.reassigned",
      "incident.annotated",
      "incident.unacknowledged",
      "incident.delegated",
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.priority_updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
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

resource "pagerduty_slack_connection" "oasys_connection" {
  source_id         = pagerduty_service.oasys.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C04E4FM3KS7"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
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

resource "pagerduty_slack_connection" "oasys_nonprod_connection" {
  source_id         = pagerduty_service.oasys_nonprod.id
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
      "incident.triggered",
      "incident.acknowledged",
      "incident.escalated",
      "incident.resolved",
      "incident.reassigned",
      "incident.annotated",
      "incident.unacknowledged",
      "incident.delegated",
      "incident.priority_updated",
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
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

resource "pagerduty_slack_connection" "laa_mlra_nonprod_connection" {
  source_id         = pagerduty_service.laa_mlra_nonprod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C022CSULB1V"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
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

resource "pagerduty_slack_connection" "laa_mlra_prod_connection" {
  source_id         = pagerduty_service.laa_mlra_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C022ZQYR30C"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
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


# Delius Jitbit Non Prod: #hmpps-jitbit-alerts-nonprod

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

resource "pagerduty_slack_connection" "jitbit_nonprod_connection" {
  source_id         = pagerduty_service.jitbit_nonprod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C04U3GUMKRR"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}

# Delius Jitbit Prod: #hmpps-jitbit-alerts-prod

resource "pagerduty_service" "jitbit_prod" {
  name                    = "Delius Jitbit Prod"
  description             = "Delius Jitbit Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "jitbit_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.jitbit_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "jitbit_prod_connection" {
  source_id         = pagerduty_service.jitbit_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C05P5QTTSUB"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}

# Slack channel: #hmpps-iaps-alerts-non-prod

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

resource "pagerduty_slack_connection" "iaps_nonprod_connection" {
  source_id         = pagerduty_service.iaps_nonprod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C04UC2L4Z47"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}

# Slack channel: #hmpps-iaps-alerts-prod

resource "pagerduty_service" "iaps_prod" {
  name                    = "Delius IAPS Prod"
  description             = "Delius IAPS Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "iaps_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.iaps_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "iaps_prod_connection" {
  source_id         = pagerduty_service.iaps_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C0502MCCYTA"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}

# Slack channel: #hmpps-iaps-alerts-prod

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

resource "pagerduty_slack_connection" "laa_mojfin_prod_connection" {
  source_id         = pagerduty_service.laa_mojfin_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C05DXKG5SQ2"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}

# # Slack channel: #mp-laa-alerts-mojfin-prod

# LAA MojFin - Dev
resource "pagerduty_service" "laa_mojfin_non_prod" {
  name                    = "Legal Aid Agency MojFin Application non-prod"
  description             = "Legal Aid Agency MojFin Application non-prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_mojfin_non_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_mojfin_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "laa_mojfin_non_prod_connection" {
  source_id         = pagerduty_service.laa_mojfin_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C05FU781K5G"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}

# # Slack channel: #mp-laa-alerts-mojfin-non-prod


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

resource "pagerduty_slack_connection" "hmpps_shef_dba_high_priority_connection" {
  source_id         = pagerduty_service.hmpps_shef_dba_high_priority.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "CDLAJTGRG"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
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

resource "pagerduty_slack_connection" "hmpps_shef_dba_low_priority_connection" {
  source_id         = pagerduty_service.hmpps_shef_dba_low_priority.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "CDLAJTGRG"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
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

resource "pagerduty_slack_connection" "hmpps_shef_dba_non_prod_connection" {
  source_id         = pagerduty_service.hmpps_shef_dba_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "CE7F6CQGH"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}

# Slack channel: dba_alerts_devtest

resource "pagerduty_service" "test_alarms" {
  name                    = "Modernisation Platform Test Alarms"
  description             = "Pagerduty integration for test alarms"
  auto_resolve_timeout    = 600
  acknowledgement_timeout = 300
  escalation_policy       = pagerduty_escalation_policy.low_priority.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "test_alarms" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.test_alarms.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}
# Slack channel: modernisation-platform

# LAA Portal - Non Prod
resource "pagerduty_service" "laa_portal_nonprod" {
  name                    = "Legal Aid Agency Portal Application Non Prod"
  description             = "Legal Aid Agency Portal Application Non Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_portal_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_portal_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# # Slack channel: #laa-portal-alerts-nonprod

# LAA Portal - Prod
resource "pagerduty_service" "laa_portal_prod" {
  name                    = "Legal Aid Agency Portal Application Production"
  description             = "Legal Aid Agency Portal Application Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_portal_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_portal_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# # Slack channel: #laa-portal-alerts-prod


# LAA MAAT - Non Prod
resource "pagerduty_service" "laa_maat_nonprod" {
  name                    = "Legal Aid Agency MAAT Application Non Prod"
  description             = "Legal Aid Agency MAAT Application Non Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_maat_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_maat_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# Slack channel: #laa-alerts-maat-nonprod

# LAA MAAT - Prod
resource "pagerduty_service" "laa_maat_prod" {
  name                    = "Legal Aid Agency MAAT Application Production"
  description             = "Legal Aid Agency MAAT Application Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_maat_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_maat_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

# Slack channel: #laa-alerts-maat-prod

# Slack channel: #csr_alerts_modernisation_platform
resource "pagerduty_service" "csr" {
  name                    = "Csr Alarms"
  description             = "Csr Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "csr_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.csr.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "csr_connection" {
  source_id         = pagerduty_service.csr.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C0617EZEVNZ" # Sending to csr_alerts_modernisation_platform
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]

    priorities = ["*"]
  }
}

# Slack channel: #csr_alerts_modernisation_platform

# DPR Non Prod

resource "pagerduty_service" "dpr_nonprod" {
  name                    = "Digital Prison Reporting Alarms Non Prod"
  description             = "Digital Prison Reporting Alarms Non Prod"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "dpr_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.dpr_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "dpr_nonprod_connection" {
  source_id         = pagerduty_service.dpr_nonprod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C061353JGDV"
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.priority_updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = ["*"]
  }
}

# DPR Non Prod

# Slack channel: #planetfm_alerts_modernisation_platform
resource "pagerduty_service" "planetfm" {
  name                    = "PlanetFM Alarms"
  description             = "PlanetFM Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "planetfm_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.planetfm.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "planetfm_connection" {
  source_id         = pagerduty_service.planetfm.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C064KHB3HB9" # Sending to planetfm_alerts_modernisation_platform
  notification_type = "responder"
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
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
      "incident.action_invocation.created",
      "incident.action_invocation.terminated",
      "incident.action_invocation.updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]

    priorities = ["*"]
  }
}
# Slack channel: #planetfm_alerts_modernisation_platform

# NCAS non prod
resource "pagerduty_service" "ncas_non_prod" {
  name                    = "NCAS non prod alarms"
  description             = "NCAS non prod alarms (preproduction)"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "ncas_non_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.ncas_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "my_connection" {
  source_id = pagerduty_service.ncas_non_prod.id
  source_type = "service_reference"
  workspace_id = local.slack_workspace_id
  channel_id = "C065VSLNFTJ"
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

# Slack channel: #cloudwatch_alerts_modernisation_platform_legacy_apps

# NCAS prod
resource "pagerduty_service" "ncas_prod" {
  name                    = "NCAS prod alarms"
  description             = "NCAS prod alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "ncas_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.ncas_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "my_connection" {
  source_id = pagerduty_service.ncas_prod.id
  source_type = "service_reference"
  workspace_id = local.slack_workspace_id
  channel_id = "C065VSLNFTJ"
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

# Slack channel: #cloudwatch_alerts_modernisation_platform_legacy_apps

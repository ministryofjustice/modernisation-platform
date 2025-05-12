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

# Delius MIS Prod
# hmpps-mis-alerts-prod
resource "pagerduty_service" "delius_mis_prod" {
  name                    = "Delius MIS Production"
  description             = "Delius MIS Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "delius_mis_prod" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.delius_mis_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "delius_mis_prod" {
  source_id         = pagerduty_service.delius_mis_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C07868KH4AK"
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

# Delius MIS Non-prod
# hmpps-mis-alerts-non-prod
resource "pagerduty_service" "delius_mis_non_prod" {
  name                    = "Delius MIS Non-production"
  description             = "Delius MIS Non-production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

# resource "pagerduty_event_orchestration" "delius_mis_non_prod" {
#   name        = "delius_mis_non_prod integration"
#   description = "Integrates delius_mis_non_prod account with PagerDuty"
#   team        = pagerduty_team.modernisation_platform.id
# }
resource "pagerduty_service_integration" "delius_mis_non_prod" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.delius_mis_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}
# resource "pagerduty_event_orchestration_integration" "delius_mis_non_prod_integration" {
#   event_orchestration = pagerduty_event_orchestration.delius_mis_non_prod.id
#   label               = "delius_mis_non_prod development"
# }
resource "pagerduty_slack_connection" "delius_mis_non_prod" {
  source_id         = pagerduty_service.delius_mis_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C07868JGQVD"
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

resource "pagerduty_slack_connection" "laa_maat_nonprod_connection" {
  source_id         = pagerduty_service.laa_maat_nonprod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C06JPN4TADB"
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

# Slack channel: #mp-laa-alerts-maat-nonprod

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

resource "pagerduty_slack_connection" "laa_maat_prod_connection" {
  source_id         = pagerduty_service.laa_maat_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C06JSKP2AM8"
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

# Slack channel: #mp-laa-alerts-maat-prod

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

resource "pagerduty_slack_connection" "ncas_non_prod_connection" {
  source_id         = pagerduty_service.ncas_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C065VSLNFTJ"
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

resource "pagerduty_slack_connection" "ncas_prod_connection" {
  source_id         = pagerduty_service.ncas_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C065VSLNFTJ"
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

# Wardship non prod
resource "pagerduty_service" "wardship_non_prod" {
  name                    = "Wardship non prod alarms"
  description             = "Wardship non prod alarms (preproduction)"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "wardship_non_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.wardship_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "wardship_non_prod_connection" {
  source_id         = pagerduty_service.wardship_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C065VSLNFTJ"
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

# Wardship prod
resource "pagerduty_service" "wardship_prod" {
  name                    = "wardship prod alarms"
  description             = "wardship prod alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "wardship_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.wardship_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "wardship_prod_connection" {
  source_id         = pagerduty_service.wardship_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C065VSLNFTJ"
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

# PRA non prod
resource "pagerduty_service" "pra_non_prod" {
  name                    = "pra non prod alarms"
  description             = "pra non prod alarms (preproduction)"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "pra_non_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.pra_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "pra_non_prod_connection" {
  source_id         = pagerduty_service.pra_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C065VSLNFTJ"
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

# pra prod
resource "pagerduty_service" "pra_prod" {
  name                    = "pra prod alarms"
  description             = "pra prod alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "pra_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.pra_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "pra_prod_connection" {
  source_id         = pagerduty_service.pra_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C065VSLNFTJ"
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

# Tipstaff non prod
resource "pagerduty_service" "tipstaff_non_prod" {
  name                    = "tipstaff non prod alarms"
  description             = "tipstaff non prod alarms (preproduction)"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "tipstaff_non_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.tipstaff_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "tipstaff_non_prod_connection" {
  source_id         = pagerduty_service.tipstaff_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C065VSLNFTJ"
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

# tipstaff prod
resource "pagerduty_service" "tipstaff_prod" {
  name                    = "tipstaff prod alarms"
  description             = "tipstaff prod alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "tipstaff_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.tipstaff_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "tipstaff_prod_connection" {
  source_id         = pagerduty_service.tipstaff_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C065VSLNFTJ"
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

# DACP non prod
resource "pagerduty_service" "dacp_non_prod" {
  name                    = "dacp non prod alarms"
  description             = "dacp non prod alarms (preproduction)"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "dacp_non_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.dacp_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "dacp_non_prod_connection" {
  source_id         = pagerduty_service.dacp_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C065VSLNFTJ"
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

# DACP prod
resource "pagerduty_service" "dacp_prod" {
  name                    = "dacp prod alarms"
  description             = "dacp prod alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "dacp_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.dacp_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "dacp_prod_connection" {
  source_id         = pagerduty_service.dacp_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C065VSLNFTJ"
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

# LAA MAAT API - Non Prod
resource "pagerduty_service" "laa_maat_api_nonprod" {
  name                    = "Legal Aid Agency MAAT API Non Prod"
  description             = "Legal Aid Agency MAAT API Non Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_maat_api_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_maat_api_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "laa_maat_api_nonprod_connection" {
  source_id         = pagerduty_service.laa_maat_api_nonprod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C06DRV52FEY"
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

# Slack channel: #laa-alerts-maat-api-nonprod

# LAA MAAT API - Prod
resource "pagerduty_service" "laa_maat_api_prod" {
  name                    = "Legal Aid Agency MAAT API Production"
  description             = "Legal Aid Agency MAAT API Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "laa_maat_api_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.laa_maat_api_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "laa_maat_api_prod_connection" {
  source_id         = pagerduty_service.laa_maat_api_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C06DGSWFVNJ"
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
# Slack channel: #laa-alerts-maat-prod

# Slack channel: #hmpps-delius-core-alerts-nonprod
# Delius Core Non Prod
resource "pagerduty_service" "delius_core_nonprod" {
  name                    = "Delius Core Non Prod"
  description             = "Delius Core Non Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "delius_core_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.delius_core_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "delius_core_nonprod_connection" {
  source_id         = pagerduty_service.delius_core_nonprod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C054P7AHFEY"
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

# Slack channel: #hmpps-delius-core-alerts-prod
# Delius Core Prod
resource "pagerduty_service" "delius_core_prod" {
  name                    = "Delius Core Prod"
  description             = "Delius Core Prod Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "delius_core_prod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.delius_core_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "delius_core_prod_connection" {
  source_id         = pagerduty_service.delius_core_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C07LTH1C5E0"
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

resource "pagerduty_service" "cwa_non_prod" {
  name                    = "CWA Non-Production Alarms"
  description             = "CWA Non-Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "cwa_non_prod" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.cwa_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "cwa_non_prod" {
  source_id         = pagerduty_service.cwa_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C076FGV8H7V"
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

# Slack channel: #mp-laa-alerts-cwa-non-prod

resource "pagerduty_service" "cwa_prod" {
  name                    = "CWA Production Alarms"
  description             = "CWA Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "cwa_prod" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.cwa_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "cwa_prod" {
  source_id         = pagerduty_service.cwa_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C07613RPX2B"
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

# Slack channel: #mp-laa-alerts-cwa-prod

resource "pagerduty_service" "apex_non_prod" {
  name                    = "APEX Non-Production Alarms"
  description             = "APEX Non-Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "apex_non_prod" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.apex_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "apex_non_prod" {
  source_id         = pagerduty_service.apex_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C03P3DZHM0U"
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
# Slack channel: #laa-alerts-apex-non-production

resource "pagerduty_service" "apex_prod" {
  name                    = "APEX Production Alarms"
  description             = "APEX Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "apex_prod" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.apex_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "apex_prod" {
  source_id         = pagerduty_service.apex_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C03P0VARA59"
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
# Slack channel: #laa-alerts-apex-production


# EDW NonProd
resource "pagerduty_service" "edw_non_prod" {
  name                    = "EDW Non-Production Alarms"
  description             = "EDW Non-Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "edw_non_prod" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.edw_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "edw_non_prod" {
  source_id         = pagerduty_service.edw_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C07AH4CDDSR"
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

# # Slack channel: #mp-laa-alerts-edw-nonprod

# EDW Prod
resource "pagerduty_service" "edw_prod" {
  name                    = "EDW Production Alarms"
  description             = "EDW Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "edw_prod" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.edw_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "edw_prod" {
  source_id         = pagerduty_service.edw_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C07ANG0BVGU"
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

# # Slack channel: #mp-laa-alerts-edw-prod


# Slack channel: #cdpt-integrated-fraud-system


# Slack channel: #cdpt-chaps

resource "pagerduty_service" "cdpt-ifs" {
  name                    = "IFS loadbalancer alarm"
  description             = "IFS loadbalancer 5xx alarm"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "cdpt_ifs_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.cdpt-ifs.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "ifs_slack" {
  source_id         = pagerduty_service.cdpt-ifs.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "CQ02MKXQU"
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

resource "pagerduty_service" "cdpt-chaps" {
  name                    = "CHAPS loadbalancer alarm"
  description             = "CHAPS loadbalancer 5xx alarm"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_event_orchestration" "cdpt_chaps_cloudwatch" {
  name        = data.pagerduty_vendor.cloudwatch.name
  description = "Integrates with PagerDuty"
  team        = pagerduty_team.modernisation_platform_members.id
}
resource "pagerduty_slack_connection" "chaps_slack" {
  source_id         = pagerduty_service.cdpt-chaps.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "CQQDV9N4R"
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

# DSO Squad alarms

locals {
  # add users to this list once they've signed into PagerDuty via SSO for first time
  dso_digital_justice_team_members = [
    "antony.gowland",
    "dominic.robinson",
    "robert.sweetman",
  ]
  dso_justice_team_members = [
    "dave.kent",
  ]

  services = {
    corporate-staff-rostering-preproduction = { slack_channel_id = "C0617EZEVNZ" } # corporate_staff_rostering_alarms
    corporate-staff-rostering-production    = { slack_channel_id = "C0617EZEVNZ" } # corporate_staff_rostering_alarms
    hmpps-domain-services-development       = { slack_channel_id = "C07J1TAG9JN" } # hmpps_domain_services_alarms_non_prod
    hmpps-domain-services-test              = { slack_channel_id = "C07J1TAG9JN" } # hmpps_domain_services_alarms_non_prod
    hmpps-domain-services-preproduction     = { slack_channel_id = "C07J1TAG9JN" } # hmpps_domain_services_alarms_non_prod
    hmpps-domain-services-production        = { slack_channel_id = "C07JQM7FY72" } # hmpps_domain_services_alarms_prod
    hmpps-oem-development                   = { slack_channel_id = "C07J1QBJXC3" } # hmpps_oem_alarms_non_prod
    hmpps-oem-test                          = { slack_channel_id = "C07J1QBJXC3" } # hmpps_oem_alarms_non_prod
    hmpps-oem-preproduction                 = { slack_channel_id = "C07J1QBJXC3" } # hmpps_oem_alarms_non_prod
    hmpps-oem-production                    = { slack_channel_id = "C07JEHTH95F" } # hmpps_oem_alarms_prod
    nomis-development                       = { slack_channel_id = "C07HW4A8K19" } # nomis_alarms_non_prod
    nomis-test                              = { slack_channel_id = "C07HW4A8K19" } # nomis_alarms_non_prod
    nomis-preproduction                     = { slack_channel_id = "C07HW4A8K19" } # nomis_alarms_non_prod
    nomis-production                        = { slack_channel_id = "C07HFLM47QX" } # nomis_alarms_prod
    nomis-combined-reporting-test           = { slack_channel_id = "C07JE9TL03T" } # nomis_combined_reporting_alarms_non_prod
    nomis-combined-reporting-preproduction  = { slack_channel_id = "C07JE9TL03T" } # nomis_combined_reporting_alarms_non_prod
    nomis-combined-reporting-production     = { slack_channel_id = "C07HYP62DT7" } # nomis_combined_reporting_alarms_prod
    nomis-data-hub-test                     = { slack_channel_id = "C07J1TP869Y" } # nomis_data_hub_alarms_non_prod
    nomis-data-hub-preproduction            = { slack_channel_id = "C07J1TP869Y" } # nomis_data_hub_alarms_non_prod
    nomis-data-hub-production               = { slack_channel_id = "C07HZ1VRP8V" } # nomis_data_hub_alarms_prod
    oasys-test                              = { slack_channel_id = "C07HMBMC8KH" } # oasys_alarms_non_prod
    oasys-preproduction                     = { slack_channel_id = "C07HMBMC8KH" } # oasys_alarms_non_prod
    oasys-production                        = { slack_channel_id = "C07J4CVFVC4" } # oasys_alarms_prod
    oasys-national-reporting-test           = { slack_channel_id = "C07HZ24GMGV" } # oasys_national_reporting_alarms_non_prod
    oasys-national-reporting-preproduction  = { slack_channel_id = "C07HZ24GMGV" } # oasys_national_reporting_alarms_non_prod
    oasys-national-reporting-production     = { slack_channel_id = "C07J1U3SN66" } # oasys_national_reporting_alarms_prod
    planetfm-preproduction                  = { slack_channel_id = "C064KHB3HB9" } # planetfm_alarms
    planetfm-production                     = { slack_channel_id = "C064KHB3HB9" } # planetfm_alarms
    dso-pipelines                           = { slack_channel_id = "C01PWKWDB9D" } # dso_alerts_pipeline
  }
  slack_events = [
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
}

data "pagerduty_user" "dso_digital_justice" {
  for_each = toset(local.dso_digital_justice_team_members)
  email    = "${each.key}${digital_email_suffix}"
}

data "pagerduty_user" "dso_justice" {
  for_each = toset(local.dso_justice_team_members)
  email    = "${each.key}${justice_email_suffix}"
}

resource "pagerduty_team" "dso" {
  name = "Digital Studio Operations"
}

resource "pagerduty_team_membership" "dso" {
  for_each = merge(data.pagerduty_user.dso_digital_justice, data.pagerduty_user.dso_justice)
  team_id  = pagerduty_team.dso.id
  user_id  = each.value.id
}

resource "pagerduty_service" "services" {
  for_each = local.services

  name                    = each.key
  description             = "${each.key}-alarms"
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"

}
resource "pagerduty_service_integration" "integrations" {
  for_each = pagerduty_service.services

  name    = data.pagerduty_vendor.cloudwatch.name
  service = each.value.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "connections" {
  for_each = local.services

  source_id         = pagerduty_service.services[each.key].id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = each.value.slack_channel_id
  notification_type = "responder"
  config {
    events     = local.slack_events
    priorities = ["*"]
  }
}

resource "pagerduty_event_orchestration_service" "default" {
  for_each = pagerduty_service.services

  service                                = each.value.id
  enable_event_orchestration_for_service = true
  set {
    id = "start"
    rule {
      label = "Set the default priority to P5 so breaches appear in the PagerDuty UI"
      actions {
        priority = data.pagerduty_priority.p5.id
      }
    }
  }
  catch_all {
    actions {}
  }
}

# END - DSO Squad alarms

# DSO Azure alerts

locals {
  dso_az_alerts = {
    channel_ids = {
      az-noms-production-1-alerts          = "C07TC0DCYJE"
      az-noms-dev-test-environments-alerts = "C0817BKDQ5T"
    }
  }
}

resource "pagerduty_service" "az_dso_alerts" {
  for_each = local.dso_az_alerts.channel_ids

  name                    = each.key
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "az_dso_alerts" {
  for_each = pagerduty_service.az_dso_alerts

  name    = data.pagerduty_vendor.cloudwatch.name
  service = each.value.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "az_dso_alerts" {
  for_each = local.dso_az_alerts.channel_ids

  source_id         = pagerduty_service.az_dso_alerts[each.key].id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = each.value
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
      "incident.reopened",
    ]
    priorities = ["*"]
  }
}

resource "pagerduty_event_orchestration_service" "az_dso_alerts" {
  for_each = pagerduty_service.az_dso_alerts

  service                                = each.value.id
  enable_event_orchestration_for_service = true
  set {
    id = "start"
    rule {
      label = "Set the default priority to P5 so breaches appear in the PagerDuty UI"
      actions {
        priority = data.pagerduty_priority.p5.id
      }
    }
  }
  catch_all {
    actions {}
  }
}

# END - DSO Azure alerts

resource "pagerduty_service" "sprinkler-development" {
  name                    = "sprinkler-development"
  description             = "sprinkler-development"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_event_orchestration" "monitor-sprinkler-integration" {
  name        = "Monitor sprinkler for orchestration"
  description = "Integrates sprinkler-development account with PagerDuty"
  team        = pagerduty_team.modernisation_platform.id
}

resource "pagerduty_event_orchestration_integration" "sprinkler_development_integration" {
  event_orchestration = pagerduty_event_orchestration.monitor-sprinkler-integration.id
  label               = "Sprinkler development"
}

resource "pagerduty_slack_connection" "sprinkler_connection" {
  source_id         = pagerduty_service.sprinkler-development.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C02PFCG8M1R"
  notification_type = "responder"
  lifecycle {
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

# Slack channel: #delius-aws-oracle-dev-alerts

resource "pagerduty_service" "delius_oracle_nonprod" {
  name                    = "Delius Oracle Non Prod"
  description             = "Delius Oracle Non Prod Alarms"
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "delius_oracle_nonprod_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.delius_oracle_nonprod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "delius_oracle_nonprod_connection" {
  source_id         = pagerduty_service.delius_oracle_nonprod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "CR82RV51Q"
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

resource "pagerduty_service" "electronic_monitoring_data" {
  name                    = "Electronic Monitoring Data Alarms"
  description             = "Electronic Monitoring Data Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "electronic_monitoring_data_cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.electronic_monitoring_data.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "electronic_monitoring_data_connection" {
  source_id         = pagerduty_service.electronic_monitoring_data.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C07TXBPBLKG"
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

# CIS NonProd
resource "pagerduty_service" "cis_non_prod" {
  name                    = "CIS Non-Production Alarms"
  description             = "CIS Non-Production Alarms"
  auto_resolve_timeout    = 345600
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.member_policy.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "cis_non_prod" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.cis_non_prod.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}

resource "pagerduty_slack_connection" "cis_non_prod" {
  source_id         = pagerduty_service.cis_non_prod.id
  source_type       = "service_reference"
  workspace_id      = local.slack_workspace_id
  channel_id        = "C08BUGTMMDJ"
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

# # Slack channel: #mp-laa-alerts-cis-nonprod

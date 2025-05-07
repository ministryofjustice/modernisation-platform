# Pagerduty integration keys
# When a new integration is created there is a uniq key that is created which is required for the endpoint
# to push notifications to pagerduty.  Add any additional integrations to the json secret below
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  description = "Pager Duty integration keys"
  kms_key_id  = aws_kms_key.pagerduty_multi_region.id
  name        = "pagerduty_integration_keys"
  policy      = data.aws_iam_policy_document.pagerduty_secret.json
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}
resource "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  secret_id = aws_secretsmanager_secret.pagerduty_integration_keys.id
  secret_string = jsonencode(merge({
    core_alerts_high_priority_cloudwatch = pagerduty_service_integration.core_alerts_high_priority_cloudwatch.integration_key,
    core_alerts_cloudwatch               = pagerduty_service_integration.core_alerts_cloudwatch.integration_key,
    security_hub                         = pagerduty_service_integration.security_hub.integration_key,
    security_hub_members                 = pagerduty_service_integration.security_hub_members.integration_key,
    ddos_cloudwatch                      = pagerduty_service_integration.ddos_cloudwatch.integration_key,
    tgw_cloudwatch                       = pagerduty_service_integration.tgw_cloudwatch.integration_key,
    networking_cloudwatch                = pagerduty_service_integration.networking_cloudwatch.integration_key,
    operations_cloudwatch                = pagerduty_service_integration.operations_cloudwatch.integration_key,
    security_cloudwatch                  = pagerduty_service_integration.security_cloudwatch.integration_key,
    laa_mlra_nonprod_alarms              = pagerduty_service_integration.laa_mlra_nonprod_cloudwatch.integration_key,
    laa_mlra_prod_alarms                 = pagerduty_service_integration.laa_mlra_prod_cloudwatch.integration_key,
    laa_oas_nonprod_alarms               = pagerduty_service_integration.laa_oas_nonprod_cloudwatch.integration_key,
    laa_oas_prod_alarms                  = pagerduty_service_integration.laa_oas_prod_cloudwatch.integration_key,
    jitbit_nonprod_alarms                = pagerduty_service_integration.jitbit_nonprod_cloudwatch.integration_key,
    jitbit_prod_alarms                   = pagerduty_service_integration.jitbit_prod_cloudwatch.integration_key,
    iaps_nonprod_alarms                  = pagerduty_service_integration.iaps_nonprod_cloudwatch.integration_key,
    iaps_prod_alarms                     = pagerduty_service_integration.iaps_prod_cloudwatch.integration_key,
    laa_mojfin_prod_alarms               = pagerduty_service_integration.laa_mojfin_prod_cloudwatch.integration_key,
    laa_mojfin_non_prod_alarms           = pagerduty_service_integration.laa_mojfin_non_prod_cloudwatch.integration_key,
    test_alarms                          = pagerduty_service_integration.test_alarms.integration_key,
    laa_portal_nonprod_alarms            = pagerduty_service_integration.laa_portal_nonprod_cloudwatch.integration_key,
    laa_portal_prod_alarms               = pagerduty_service_integration.laa_portal_prod_cloudwatch.integration_key
    laa_maat_nonprod_alarms              = pagerduty_service_integration.laa_maat_nonprod_cloudwatch.integration_key,
    laa_maat_prod_alarm                  = pagerduty_service_integration.laa_maat_prod_cloudwatch.integration_key,
    dpr_nonprod_alarms                   = pagerduty_service_integration.dpr_nonprod_cloudwatch.integration_key,
    ncas_non_prod_alarms                 = pagerduty_service_integration.ncas_non_prod_cloudwatch.integration_key,
    ncas_prod_alarms                     = pagerduty_service_integration.ncas_prod_cloudwatch.integration_key,
    wardship_non_prod_alarms             = pagerduty_service_integration.wardship_non_prod_cloudwatch.integration_key,
    wardship_prod_alarms                 = pagerduty_service_integration.wardship_prod_cloudwatch.integration_key,
    pra_non_prod_alarms                  = pagerduty_service_integration.pra_non_prod_cloudwatch.integration_key,
    pra_prod_alarms                      = pagerduty_service_integration.pra_prod_cloudwatch.integration_key,
    tipstaff_non_prod_alarms             = pagerduty_service_integration.tipstaff_non_prod_cloudwatch.integration_key,
    tipstaff_prod_alarms                 = pagerduty_service_integration.tipstaff_prod_cloudwatch.integration_key,
    dacp_non_prod_alarms                 = pagerduty_service_integration.dacp_non_prod_cloudwatch.integration_key,
    dacp_prod_alarms                     = pagerduty_service_integration.dacp_prod_cloudwatch.integration_key,
    laa_maat_api_nonprod_alarms          = pagerduty_service_integration.laa_maat_api_nonprod_cloudwatch.integration_key,
    laa_maat_api_prod_alarms             = pagerduty_service_integration.laa_maat_api_prod_cloudwatch.integration_key,
    delius_core_nonprod_alarms           = pagerduty_service_integration.delius_core_nonprod_cloudwatch.integration_key
    delius_core_prod_alarms              = pagerduty_service_integration.delius_core_prod_cloudwatch.integration_key
    delius_oracle_nonprod_alarms         = pagerduty_service_integration.delius_oracle_nonprod_cloudwatch.integration_key
    laa_cwa_nonprod_alarms               = pagerduty_service_integration.cwa_non_prod.integration_key
    laa_cwa_prod_alarms                  = pagerduty_service_integration.cwa_prod.integration_key
    laa_apex_nonprod_alarms              = pagerduty_service_integration.apex_non_prod.integration_key
    laa_apex_prod_alarms                 = pagerduty_service_integration.apex_prod.integration_key
    electronic_monitoring_data_alarms    = pagerduty_service_integration.electronic_monitoring_data_cloudwatch.integration_key
    # delius_mis_non_prod                     = pagerduty_event_orchestration_integration.delius_mis_non_prod_integration.parameters[0].routing_key
    delius_mis_nonprod_alarms = pagerduty_service_integration.delius_mis_non_prod.integration_key
    delius_mis_prod_alarms    = pagerduty_service_integration.delius_mis_prod.integration_key
    laa_edw_nonprod_alarms    = pagerduty_service_integration.edw_non_prod.integration_key
    laa_edw_prod_alarms       = pagerduty_service_integration.edw_prod.integration_key
    cdpt-ifs-alarms           = pagerduty_service_integration.cdpt_ifs_cloudwatch.integration_key
    sprinkler_development     = pagerduty_event_orchestration_integration.sprinkler_development_integration.parameters[0].routing_key
    laa_cis_nonprod_alarms    = pagerduty_service_integration.cis_non_prod.integration_key
    },
    {
      for key, integration in pagerduty_service_integration.integrations : key => integration.integration_key
    },
    {
      for key, integration in pagerduty_service_integration.az_dso_alerts : key => integration.integration_key
    }
  ))
}

# Pagerduty token
# Required for Terraform to make api calls to pagerduty, set in the console, new tokens available from #ops-engineering
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "pagerduty_token" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "pagerduty_token"
  description = "PagerDuty api token, used by PagerDuty Terraform to manage most PagerDuty resources"
  kms_key_id  = aws_kms_key.pagerduty_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Pagerduty user token
# Required for Terraform to make api calls to pagerduty, set in the console, new tokens available from #ops-engineering
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "pagerduty_user_token" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "pagerduty_userapi_token"
  kms_key_id  = aws_kms_key.pagerduty_multi_region.id
  description = "PagerDuty api user level token, used to link services to Slack channels.  A valid PD and Slack user needed (to authorise against a slack user), needed in addition to the org level token"
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

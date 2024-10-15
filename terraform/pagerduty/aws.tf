# Pagerduty integration keys
# When a new integration is created there is a uniq key that is created which is required for the endpoint
# to push notifications to pagerduty.  Add any additional integrations to the json secret below
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  description = "Pager Duty integration keys"
  kms_key_id  = aws_kms_key.pagerduty.id
  name        = "pagerduty_integration_keys"
  policy      = data.aws_iam_policy_document.pagerduty_secret.json
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}
resource "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  secret_id = aws_secretsmanager_secret.pagerduty_integration_keys.id
  secret_string = jsonencode({
    core_alerts_cloudwatch          = pagerduty_service_integration.core_alerts_cloudwatch.integration_key,
    ddos_cloudwatch                 = pagerduty_service_integration.ddos_cloudwatch.integration_key,
    tgw_cloudwatch                  = pagerduty_service_integration.tgw_cloudwatch.integration_key,
    networking_cloudwatch           = pagerduty_service_integration.networking_cloudwatch.integration_key,
    operations_cloudwatch           = pagerduty_service_integration.operations_cloudwatch.integration_key,
    security_cloudwatch             = pagerduty_service_integration.security_cloudwatch.integration_key,
    laa_mlra_nonprod_alarms         = pagerduty_service_integration.laa_mlra_nonprod_cloudwatch.integration_key,
    laa_mlra_prod_alarms            = pagerduty_service_integration.laa_mlra_prod_cloudwatch.integration_key,
    laa_oas_nonprod_alarms          = pagerduty_service_integration.laa_oas_nonprod_cloudwatch.integration_key,
    laa_oas_prod_alarms             = pagerduty_service_integration.laa_oas_prod_cloudwatch.integration_key,
    jitbit_nonprod_alarms           = pagerduty_service_integration.jitbit_nonprod_cloudwatch.integration_key,
    jitbit_prod_alarms              = pagerduty_service_integration.jitbit_prod_cloudwatch.integration_key,
    iaps_nonprod_alarms             = pagerduty_service_integration.iaps_nonprod_cloudwatch.integration_key,
    iaps_prod_alarms                = pagerduty_service_integration.iaps_prod_cloudwatch.integration_key,
    laa_mojfin_prod_alarms          = pagerduty_service_integration.laa_mojfin_prod_cloudwatch.integration_key,
    laa_mojfin_non_prod_alarms      = pagerduty_service_integration.laa_mojfin_non_prod_cloudwatch.integration_key,
    test_alarms                     = pagerduty_service_integration.test_alarms.integration_key,
    laa_portal_nonprod_alarms       = pagerduty_service_integration.laa_portal_nonprod_cloudwatch.integration_key,
    laa_portal_prod_alarms          = pagerduty_service_integration.laa_portal_prod_cloudwatch.integration_key
    laa_maat_nonprod_alarms         = pagerduty_service_integration.laa_maat_nonprod_cloudwatch.integration_key,
    laa_maat_prod_alarm             = pagerduty_service_integration.laa_maat_prod_cloudwatch.integration_key,
    dpr_nonprod_alarms              = pagerduty_service_integration.dpr_nonprod_cloudwatch.integration_key,
    ncas_non_prod_alarms            = pagerduty_service_integration.ncas_non_prod_cloudwatch.integration_key,
    ncas_prod_alarms                = pagerduty_service_integration.ncas_prod_cloudwatch.integration_key,
    wardship_non_prod_alarms        = pagerduty_service_integration.wardship_non_prod_cloudwatch.integration_key,
    wardship_prod_alarms            = pagerduty_service_integration.wardship_prod_cloudwatch.integration_key,
    pra_non_prod_alarms             = pagerduty_service_integration.pra_non_prod_cloudwatch.integration_key,
    pra_prod_alarms                 = pagerduty_service_integration.pra_prod_cloudwatch.integration_key,
    tipstaff_non_prod_alarms        = pagerduty_service_integration.tipstaff_non_prod_cloudwatch.integration_key,
    tipstaff_prod_alarms            = pagerduty_service_integration.tipstaff_prod_cloudwatch.integration_key,
    dacp_non_prod_alarms            = pagerduty_service_integration.dacp_non_prod_cloudwatch.integration_key,
    dacp_prod_alarms                = pagerduty_service_integration.dacp_prod_cloudwatch.integration_key,
    laa_maat_api_nonprod_alarms     = pagerduty_service_integration.laa_maat_api_nonprod_cloudwatch.integration_key,
    laa_maat_api_prod_alarms        = pagerduty_service_integration.laa_maat_api_prod_cloudwatch.integration_key,
    delius_core_nonprod_alarms      = pagerduty_service_integration.delius_core_nonprod_cloudwatch.integration_key
    delius_oracle_nonprod_alarms    = pagerduty_service_integration.delius_oracle_nonprod_cloudwatch.integration_key
    delius_nextcloud_nonprod_alarms = pagerduty_service_integration.delius_nextcloud_nonprod_cloudwatch.integration_key
    delius_nextcloud_prod_alarms    = pagerduty_service_integration.delius_nextcloud_prod_cloudwatch.integration_key
    laa_cwa_nonprod_alarms          = pagerduty_service_integration.cwa_non_prod.integration_key
    laa_cwa_prod_alarms             = pagerduty_service_integration.cwa_prod.integration_key
    laa_apex_nonprod_alarms         = pagerduty_service_integration.apex_non_prod.integration_key
    laa_apex_prod_alarms            = pagerduty_service_integration.apex_prod.integration_key
    # delius_mis_non_prod                     = pagerduty_event_orchestration_integration.delius_mis_non_prod_integration.parameters[0].routing_key
    delius_mis_nonprod_alarms               = pagerduty_service_integration.delius_mis_non_prod.integration_key
    delius_mis_prod_alarms                  = pagerduty_service_integration.delius_mis_prod.integration_key
    laa_edw_nonprod_alarms                  = pagerduty_service_integration.edw_non_prod.integration_key
    laa_edw_prod_alarms                     = pagerduty_service_integration.edw_prod.integration_key
    cdpt-ifs-alarms                         = pagerduty_service_integration.cdpt_ifs_cloudwatch.integration_key
    sprinkler_development                   = pagerduty_event_orchestration_integration.sprinkler_development_integration.parameters[0].routing_key
    corporate-staff-rostering-preproduction = pagerduty_service_integration.integrations["corporate-staff-rostering-preproduction"].integration_key
    corporate-staff-rostering-production    = pagerduty_service_integration.integrations["corporate-staff-rostering-production"].integration_key
    hmpps-domain-services-development       = pagerduty_service_integration.integrations["hmpps-domain-services-development"].integration_key
    hmpps-domain-services-preproduction     = pagerduty_service_integration.integrations["hmpps-domain-services-preproduction"].integration_key
    hmpps-domain-services-production        = pagerduty_service_integration.integrations["hmpps-domain-services-production"].integration_key
    hmpps-domain-services-test              = pagerduty_service_integration.integrations["hmpps-domain-services-test"].integration_key
    hmpps-oem-development                   = pagerduty_service_integration.integrations["hmpps-oem-development"].integration_key
    hmpps-oem-preproduction                 = pagerduty_service_integration.integrations["hmpps-oem-preproduction"].integration_key
    hmpps-oem-production                    = pagerduty_service_integration.integrations["hmpps-oem-production"].integration_key
    hmpps-oem-test                          = pagerduty_service_integration.integrations["hmpps-oem-test"].integration_key
    nomis-development                       = pagerduty_service_integration.integrations["nomis-development"].integration_key
    nomis-preproduction                     = pagerduty_service_integration.integrations["nomis-preproduction"].integration_key
    nomis-production                        = pagerduty_service_integration.integrations["nomis-production"].integration_key
    nomis-test                              = pagerduty_service_integration.integrations["nomis-test"].integration_key
    nomis-combined-reporting-preproduction  = pagerduty_service_integration.integrations["nomis-combined-reporting-preproduction"].integration_key
    nomis-combined-reporting-production     = pagerduty_service_integration.integrations["nomis-combined-reporting-production"].integration_key
    nomis-combined-reporting-test           = pagerduty_service_integration.integrations["nomis-combined-reporting-test"].integration_key
    nomis-data-hub-preproduction            = pagerduty_service_integration.integrations["nomis-data-hub-preproduction"].integration_key
    nomis-data-hub-production               = pagerduty_service_integration.integrations["nomis-data-hub-production"].integration_key
    nomis-data-hub-test                     = pagerduty_service_integration.integrations["nomis-data-hub-test"].integration_key
    oasys-preproduction                     = pagerduty_service_integration.integrations["oasys-preproduction"].integration_key
    oasys-production                        = pagerduty_service_integration.integrations["oasys-production"].integration_key
    oasys-test                              = pagerduty_service_integration.integrations["oasys-test"].integration_key
    oasys-national-reporting-preproduction  = pagerduty_service_integration.integrations["oasys-national-reporting-preproduction"].integration_key
    oasys-national-reporting-production     = pagerduty_service_integration.integrations["oasys-national-reporting-production"].integration_key
    oasys-national-reporting-test           = pagerduty_service_integration.integrations["oasys-national-reporting-test"].integration_key
    planetfm-preproduction                  = pagerduty_service_integration.integrations["planetfm-preproduction"].integration_key
    planetfm-production                     = pagerduty_service_integration.integrations["planetfm-production"].integration_key
  })
}

# Pagerduty token
# Required for Terraform to make api calls to pagerduty, set in the console, new tokens available from #ops-engineering
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "pagerduty_token" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "pagerduty_token"
  description = "PagerDuty api token, used by PagerDuty Terraform to manage most PagerDuty resources"
  kms_key_id  = aws_kms_key.pagerduty.id
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
  kms_key_id  = aws_kms_key.pagerduty.id
  description = "PagerDuty api user level token, used to link services to Slack channels.  A valid PD and Slack user needed (to authorise against a slack user), needed in addition to the org level token"
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

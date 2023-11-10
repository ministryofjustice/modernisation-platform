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
}

resource "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  secret_id = aws_secretsmanager_secret.pagerduty_integration_keys.id
  secret_string = jsonencode({
    core_alerts_cloudwatch       = pagerduty_service_integration.core_alerts_cloudwatch.integration_key,
    ddos_cloudwatch              = pagerduty_service_integration.ddos_cloudwatch.integration_key,
    tgw_cloudwatch               = pagerduty_service_integration.tgw_cloudwatch.integration_key,
    networking_cloudwatch        = pagerduty_service_integration.networking_cloudwatch.integration_key,
    operations_cloudwatch        = pagerduty_service_integration.operations_cloudwatch.integration_key,
    security_cloudwatch          = pagerduty_service_integration.security_cloudwatch.integration_key,
    nomis_alarms                 = pagerduty_service_integration.nomis_cloudwatch.integration_key,
    nomis_nonprod_alarms         = pagerduty_service_integration.nomis_nonprod_cloudwatch.integration_key,
    laa_mlra_nonprod_alarms      = pagerduty_service_integration.laa_mlra_nonprod_cloudwatch.integration_key,
    laa_mlra_prod_alarms         = pagerduty_service_integration.laa_mlra_prod_cloudwatch.integration_key,
    laa_oas_nonprod_alarms       = pagerduty_service_integration.laa_oas_nonprod_cloudwatch.integration_key,
    laa_oas_prod_alarms          = pagerduty_service_integration.laa_oas_prod_cloudwatch.integration_key,
    jitbit_nonprod_alarms        = pagerduty_service_integration.jitbit_nonprod_cloudwatch.integration_key,
    jitbit_prod_alarms           = pagerduty_service_integration.jitbit_prod_cloudwatch.integration_key,
    iaps_nonprod_alarms          = pagerduty_service_integration.iaps_nonprod_cloudwatch.integration_key,
    iaps_prod_alarms             = pagerduty_service_integration.iaps_prod_cloudwatch.integration_key,
    laa_mojfin_prod_alarms       = pagerduty_service_integration.laa_mojfin_prod_cloudwatch.integration_key,
    laa_mojfin_non_prod_alarms   = pagerduty_service_integration.laa_mojfin_non_prod_cloudwatch.integration_key,
    hmpps_shef_dba_high_priority = pagerduty_service_integration.hmpps_shef_dba_high_priority.integration_key,
    hmpps_shef_dba_low_priority  = pagerduty_service_integration.hmpps_shef_dba_low_priority.integration_key,
    hmpps_shef_dba_non_prod      = pagerduty_service_integration.hmpps_shef_dba_non_prod.integration_key,
    oasys_alarms                 = pagerduty_service_integration.oasys_cloudwatch.integration_key,
    oasys_nonprod_alarms         = pagerduty_service_integration.oasys_nonprod_cloudwatch.integration_key
    test_alarms                  = pagerduty_service_integration.test_alarms.integration_key,
    laa_portal_nonprod_alarms    = pagerduty_service_integration.laa_portal_nonprod_cloudwatch.integration_key,
    laa_portal_prod_alarms       = pagerduty_service_integration.laa_portal_prod_cloudwatch.integration_key
    laa_maat_nonprod_alarms      = pagerduty_service_integration.laa_maat_nonprod_cloudwatch.integration_key,
    laa_maat_prod_alarm          = pagerduty_service_integration.laa_maat_prod_cloudwatch.integration_key,
    csr_alarms                   = pagerduty_service_integration.csr_cloudwatch.integration_key,
    dpr_nonprod_alarms           = pagerduty_service_integration.dpr_nonprod_cloudwatch.integration_key,
    planetfm_alarms              = pagerduty_service_integration.planetfm_cloudwatch.integration_key,
    ncas_non_prod_alarms         = pagerduty_service_integration.ncas_non_prod_cloudwatch.integration_key,
  })
}

# Pagerduty token
# Required for Terraform to make api calls to pagerduty, set in the console, new tokens available from #ops-engineering
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "pagerduty_token" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "pagerduty_token"
  description = "PagerDuty api token"
  tags        = local.tags
}

# Pagerduty user token
# Required for Terraform to make api calls to pagerduty, set in the console, new tokens available from #ops-engineering
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "pagerduty_user_token" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "pagerduty_userapi_token"
  description = "PagerDuty api user token"
  tags        = local.tags
}

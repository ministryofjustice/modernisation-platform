resource "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  name        = "pagerduty_integration_keys"
  description = "Pager Duty integration keys"
  tags        = local.tags
}

resource "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  secret_id = aws_secretsmanager_secret.pagerduty_integration_keys.id
  secret_string = jsonencode({
    core_alerts_cloudwatch = pagerduty_service_integration.cloudwatch.integration_key
  })
}

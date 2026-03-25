# tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "iam_credential_alert" {
  #checkov:skip=CKV_AWS_26:"encrypted topics do not work with pagerduty subscription"
  name = "iam-credential-exposed-alert"
}

data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  provider = aws.modernisation-platform
  name     = "pagerduty_integration_keys"
}

data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
}

locals {
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)
}

module "pagerduty_iam_credential_alert" {
  depends_on = [
    aws_sns_topic.iam_credential_alert
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=d88bd90d490268896670a898edfaba24bba2f8ab" # v3.0.0
  sns_topics                = [aws_sns_topic.iam_credential_alert.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_high_priority_cloudwatch"]
}
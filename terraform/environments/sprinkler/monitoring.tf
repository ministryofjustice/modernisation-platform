## Pager duty integration

# # SNS topic for monitoring to send alarms to
# resource "aws_sns_topic" "sprinkler_ddos_alarm" {
#   name              = "sprinkler_ddos_alarm"
#   kms_master_key_id = aws_kms_key.pagerduty.id
#   #data.aws_kms_key.sns.id
# }

# Get the map of pagerduty integration keys from the modernisation platform account
data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  provider = aws.modernisation-platform
  name     = "pagerduty_integration_keys"
}
data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
}

# Add a local to get the keys
locals {
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)
}

resource "aws_sns_topic" "sprinkler_sns" {
# checkov:skip=CKV_AWS_26:It is encrypted
  name  = "sprinkler_sns" 
}

# link the sns topic to the service
module "pagerduty_core_alerts" {
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = [aws_sns_topic.sprinkler_sns.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["ddos_cloudwatch"]
}
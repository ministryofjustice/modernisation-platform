# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  provider = aws.modernisation-platform
  name     = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

# Get the map of pagerduty integration keys
data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  provider = aws.modernisation-platform
  name     = "pagerduty_integration_keys"
}

data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
}


# Data for Firehose Endpoint URL & Key that are held in secrets manager.

# 1. Secrets for Firewall-related log data.

# NonProd
data "aws_secretsmanager_secret" "kinesis_preprod_firewall_secret_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_preprod_firewall_secret"
}

data "aws_secretsmanager_secret_version" "kinesis_preprod_firewall_secret_arn_version" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.kinesis_preprod_firewall_secret_arn.id
}

data "aws_secretsmanager_secret" "kinesis_preprod_firewall_endpoint_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_preprod_firewall_endpoint"
}

data "aws_secretsmanager_secret_version" "kinesis_preprod_firewall_endpoint_arn_version" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.kinesis_preprod_firewall_endpoint_arn.id
}

# Prod
data "aws_secretsmanager_secret" "kinesis_prod_firewall_secret_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_prod_firewall_secret"
}

data "aws_secretsmanager_secret_version" "kinesis_prod_firewall_secret_arn_version" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.kinesis_prod_firewall_secret_arn.id
}

data "aws_secretsmanager_secret" "kinesis_prod_firewall_endpoint_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_prod_firewall_endpoint"
}

data "aws_secretsmanager_secret_version" "kinesis_prod_firewall_endpoint_arn_version" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.kinesis_prod_firewall_endpoint_arn.id
}


# 2. Secrets related to VPC flow log data.

# NonProd
data "aws_secretsmanager_secret" "kinesis_preprod_network_secret_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_preprod_network_secret"
}

data "aws_secretsmanager_secret_version" "kinesis_preprod_network_secret_arn_version" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.kinesis_preprod_network_secret_arn.id
}

data "aws_secretsmanager_secret" "kinesis_preprod_network_endpoint_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_preprod_network_endpoint"
}

data "aws_secretsmanager_secret_version" "kinesis_preprod_network_endpoint_arn_version" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.kinesis_preprod_network_endpoint_arn.id
}

#Prod
data "aws_secretsmanager_secret" "kinesis_prod_network_secret_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_prod_network_secret"
}

data "aws_secretsmanager_secret_version" "kinesis_prod_network_secret_arn_version" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.kinesis_prod_network_secret_arn.id
}

data "aws_secretsmanager_secret" "kinesis_prod_network_endpoint_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_prod_network_endpoint"
}

data "aws_secretsmanager_secret_version" "kinesis_prod_network_endpoint_arn_version" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.kinesis_prod_network_endpoint_arn.id
}


# Environment logging secret KMS key
resource "aws_kms_key" "environment_logging" {
  description             = "environment-logging"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.environment_logging.json
}

resource "aws_kms_alias" "environment_logging" {
  name          = "alias/environment-logging"
  target_key_id = aws_kms_key.environment_logging.key_id
}

# Static code analysis ignores:
# - CKV_AWS_109 and CKV_AWS_111: Ignore warnings regarding resource = ["*"]. See https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
#   Specifically: "In a key policy, the value of the Resource element is "*", which means "this KMS key." The asterisk ("*") identifies the KMS key to which the key policy is attached."
data "aws_iam_policy_document" "environment_logging" {
  # checkov:skip=CKV_AWS_109: "Key policy requires asterisk resource"
  # checkov:skip=CKV_AWS_111: "Key policy requires asterisk resource"
  # checkov:skip=CKV_AWS_356: "Account root user requires full access"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow CloudWatch access"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.eu-west-2.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:region:${data.aws_caller_identity.current.account_id}:*"]
      variable = "kms:EncryptionContext:aws:logs:arn"
    }
  }
}


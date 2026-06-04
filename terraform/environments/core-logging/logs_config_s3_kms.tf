## KMS Key - Source Region (eu-west-2)
resource "aws_kms_key" "config_logs" {
  description             = "KMS key for encrypting AWS Config logs in central bucket"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms_config_logs.json
  tags                    = { Name = "modernisation-platform-config-logs-kms" }
}

resource "aws_kms_alias" "config_logs" {
  name          = "alias/config-logs-kms"
  target_key_id = aws_kms_key.config_logs.id
}

## KMS Policy Document (Source Region)
data "aws_iam_policy_document" "kms_config_logs" {
  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "role is resticted by limited actions in member account"
  statement {
    sid       = "AllowRootAccess"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "AllowUseByAWSConfig"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = [data.aws_organizations_organization.moj_root_account.id]
    }
  }

  statement {
    sid       = "AllowReplicationAccess"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-config/s3-replication"
      ]
    }
  }
}

resource "aws_kms_key" "config_logs_replication" {
  provider                = aws.modernisation-platform-eu-west-1
  description             = "KMS key for replicated AWS Config logs in eu-west-1"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms_config_logs_replication.json
  tags                    = { Name = "modernisation-platform-config-logs-kms-replication" }
}

resource "aws_kms_alias" "config_logs_replication" {
  provider      = aws.modernisation-platform-eu-west-1
  name          = "alias/config-logs-kms-replication"
  target_key_id = aws_kms_key.config_logs_replication.id
}


## KMS Policy Document (Replication)
data "aws_iam_policy_document" "kms_config_logs_replication" {
  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "role is resticted by limited actions in member account"
  statement {
    sid       = "AllowRootAccess"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid       = "AllowReplicationAccess"
    effect    = "Allow"
    actions   = ["kms:ReEncrypt*", "kms:Encrypt", "kms:Describe"]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-config/s3-replication"
      ]
    }
  }
}

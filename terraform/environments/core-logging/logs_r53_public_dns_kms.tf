## KMS Key - Source Region (eu-west-2)
resource "aws_kms_key" "r53_public_dns_logs" {
  description             = "KMS key for encrypting Route 53 public DNS logs"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms_r53_public_dns_logs.json
  tags                    = { Name = "modernisation-platform-r53-public-dns-logs-kms" }
}

resource "aws_kms_alias" "r53_public_dns_logs" {
  name          = "alias/r53-public-dns-logs-kms"
  target_key_id = aws_kms_key.r53_public_dns_logs.id
}

## KMS Policy Document (Source Region)
data "aws_iam_policy_document" "kms_r53_public_dns_logs" {
  # checkov:skip=CKV_AWS_109: "Policy is restricted to internal account and roles"
  # checkov:skip=CKV_AWS_111: "Write access allowed only for approved services"
  # checkov:skip=CKV_AWS_356: "Wildcard used in internal context and not public"

  statement {
    sid       = "AllowKeyAdmin"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "AllowFirehoseAndLogsEncrypt"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com",
        "logs.${data.aws_region.current.region}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.environment_management.account_ids["core-network-services-production"]]
    }
  }

  statement {
    sid    = "AllowSQSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["sqs.amazonaws.com"]
    }
  }

  statement {
    sid    = "AllowS3Replication"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:aws:sts::%s:assumed-role/AWSS3BucketReplication-r53-public-dns-logs/s3-replication",
          data.aws_caller_identity.current.account_id
        )
      ]
    }
  }
}

resource "aws_kms_key" "r53_public_dns_logs_replication" {
  provider                = aws.modernisation-platform-eu-west-1
  description             = "KMS key for replicated Route 53 public DNS logs in eu-west-1"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms_r53_public_dns_logs_replication.json
  tags                    = { Name = "modernisation-platform-r53-public-dns-logs-kms-replication" }
}

resource "aws_kms_alias" "r53_public_dns_logs_replication" {
  provider      = aws.modernisation-platform-eu-west-1
  name          = "alias/r53-public-dns-logs-kms-replication"
  target_key_id = aws_kms_key.r53_public_dns_logs_replication.id
}


## KMS Policy Document (Replication)
data "aws_iam_policy_document" "kms_r53_public_dns_logs_replication" {
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
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-r53-public-dns-logs/s3-replication"
      ]
    }
  }
}

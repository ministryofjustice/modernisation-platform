# Source KMS Key
resource "aws_kms_key" "s3_modernisation_platform_waf_logs" {
  description             = "KMS key for modernisation platform waf logs bucket"
  policy                  = data.aws_iam_policy_document.kms_logging_modernisation_platform_waf_logs.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = local.tags
}

resource "aws_kms_alias" "s3_modernisation_platform_waf_logs" {
  name          = "alias/s3-modernisation-platform-waf-logs"
  target_key_id = aws_kms_key.s3_modernisation_platform_waf_logs.id
}

data "aws_iam_policy_document" "kms_logging_modernisation_platform_waf_logs" {
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
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.current.id]
    }
  }

  statement {
    sid    = "AllowCortexXsiamDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cortex_xsiam_role.arn]
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
          "arn:aws:sts::%s:assumed-role/AWSS3BucketReplication-waf-logs/s3-replication",
          data.aws_caller_identity.current.account_id
        )
      ]
    }
  }
}

# Destination KMS Key
resource "aws_kms_key" "s3_modernisation_platform_waf_logs_eu_west_1_replication" {
  provider                = aws.modernisation-platform-eu-west-1
  description             = "KMS key for modernisation platform waf logs bucket replication (eu-west-1)"
  policy                  = data.aws_iam_policy_document.kms_logging_modernisation_platform_waf_logs_replication.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = local.tags
}

resource "aws_kms_alias" "s3_logging_modernisation_platform_waf_logs_eu_west_1_replication" {
  provider      = aws.modernisation-platform-eu-west-1
  name          = "alias/s3-modernisation-platform-waf-logs-eu-west-1-replication"
  target_key_id = aws_kms_key.s3_modernisation_platform_waf_logs_eu_west_1_replication.id
}

data "aws_iam_policy_document" "kms_logging_modernisation_platform_waf_logs_replication" {
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
          "arn:aws:sts::%s:assumed-role/AWSS3BucketReplication-waf-logs/s3-replication",
          data.aws_caller_identity.current.account_id
        )
      ]
    }
  }
}

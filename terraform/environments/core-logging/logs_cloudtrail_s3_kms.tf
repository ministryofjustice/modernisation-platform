resource "aws_kms_key" "s3_logging_cloudtrail" {
  description             = "s3-logging-cloudtrail"
  policy                  = data.aws_iam_policy_document.kms_logging_cloudtrail.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "s3_logging_cloudtrail" {
  name          = "alias/s3-logging-cloudtrail"
  target_key_id = aws_kms_key.s3_logging_cloudtrail.id
}

data "aws_iam_policy_document" "kms_logging_cloudtrail" {
  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "role is resticted by limited actions in member account"

  statement {
    sid    = "Allow management access of the key to the logging account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }

  statement {
    sid    = "Enable decrypt access to accounts within the organisation"
    effect = "Allow"
    actions = [
      "kms:Describe*",
      "kms:Decrypt*"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.moj_root_account.id
      ]
    }
  }

  statement {
    sid    = "Allow use of the key including encryption"
    effect = "Allow"
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt*",
      "kms:Describe*",
      "kms:Decrypt*"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com", "cloudtrail.amazonaws.com", "logs.amazonaws.com"]
    }
  }

  statement {
    sid    = "Allow use of the key by SQS"
    effect = "Allow"
    actions = [
      "kms:Describe*",
      "kms:Decrypt*"
    ]
    resources = [aws_sqs_queue.mp_cloudtrail_log_queue.arn]
    principals {
      type        = "Service"
      identifiers = ["sqs.amazonaws.com"]
    }
  }

  statement {
    sid    = "Allow use of the key by the ModernisationPlatformAccess role in all MP accounts"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt*",
      "kms:Describe*",
      "kms:Decrypt*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.moj_root_account.id]
    }
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/ModernisationPlatformAccess"]
    }
  }

  statement {
    sid    = "Allow key decryption to STS bucket replication roles"
    effect = "Allow"
    actions = [
      "kms:Decrypt*"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-cloudtrail/s3-replication",
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-cloudtrail-logging/s3-replication",
      ]
    }
  }
}

# KMS Destination
resource "aws_kms_key" "s3_logging_cloudtrail_eu-west-1_replication" {
  provider = aws.modernisation-platform-eu-west-1

  description             = "s3-logging-cloudtrail-eu-west-1-replication"
  policy                  = data.aws_iam_policy_document.kms_logging_cloudtrail_replication.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = { Name = "${local.application_name}-s3-logging-cloudtrail-kms" }
}

resource "aws_kms_alias" "s3_logging_cloudtrail_eu-west-1_replication" {
  provider = aws.modernisation-platform-eu-west-1

  name          = "alias/s3-logging-cloudtrail-eu-west-1-replication"
  target_key_id = aws_kms_key.s3_logging_cloudtrail_eu-west-1_replication.id
}

data "aws_iam_policy_document" "kms_logging_cloudtrail_replication" {
  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "role is resticted by limited actions in member account"
  statement {
    sid    = "Allow management access of the key to the logging account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }

  statement {
    sid    = "Allow key decryption to STS bucket replication roles"
    effect = "Allow"
    actions = [
      "kms:ReEncrypt*",
      "kms:Encrypt*",
      "kms:Describe*"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-cloudtrail/s3-replication",
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-cloudtrail-logging/s3-replication",
      ]
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "ebs" {
  description         = format("EBS symmetric KMS key for %s", var.business_unit)
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms.json
  tags                = merge(var.tags, { Name = format("KMS-EBS-%s", var.business_unit) })
}

resource "aws_kms_alias" "ebs" {
  target_key_id = aws_kms_key.ebs.id
  name          = format("alias/ebs-%s", var.business_unit)
}

resource "aws_kms_key" "general" {
  description         = format("General symmetric KMS key for %s", var.business_unit)
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms.json
  tags                = merge(var.tags, { Name = format("KMS-General-%s", var.business_unit) })
}

resource "aws_kms_alias" "general" {
  target_key_id = aws_kms_key.general.id
  name          = format("alias/general-%s", var.business_unit)
}

resource "aws_kms_key" "rds" {
  description         = format("RDS symmetric KMS key for %s", var.business_unit)
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms.json
  tags                = merge(var.tags, { Name = format("KMS-RDS-%s", var.business_unit) })
}

resource "aws_kms_alias" "rds" {
  target_key_id = aws_kms_key.rds.id
  name          = format("alias/rds-%s", var.business_unit)
}

data "aws_iam_policy_document" "kms" {
  # checkov:skip=CKV_AWS_109
  # checkov:skip=CKV_AWS_111
  # Allow root users full management access to key
  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]

    resources = ["*"] # Represents the key to which this policy is attached

    # AWS should add the AWS account by default but adding here for visibility
    # See https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html#key-policy-default-allow-root-enable-iam
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] #
    }
  }

  # Allow business unit accounts limited access to key
  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = ["*"]

    # Feed in AWS account IDs
    principals {
      type        = "AWS"
      identifiers = var.business_unit_account_ids
    }
  }
}
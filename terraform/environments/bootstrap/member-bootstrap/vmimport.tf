# VM Import/Export service role required by ec2:ImportImage and ec2:ImportSnapshot.
# AWS expects this role to be named vmimport and trusted by vmie.amazonaws.com.

data "aws_iam_policy_document" "vmimport_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vmie.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["vmimport"]
    }
  }
}

resource "aws_iam_role" "vmimport" {
  count = local.account_data.account-type == "member" ? 1 : 0

  name               = "vmimport"
  assume_role_policy = data.aws_iam_policy_document.vmimport_assume_role.json
  tags               = local.tags
}

#tfsec:ignore:aws-iam-no-policy-wildcards
#checkov:skip=CKV_AWS_356: VM import must access caller-provided S3 objects and KMS keys.
data "aws_iam_policy_document" "vmimport" {
  statement {
    sid    = "VmImportS3Read"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "VmImportEc2Import"
    effect = "Allow"
    actions = [
      "ec2:ModifySnapshotAttribute",
      "ec2:CopySnapshot",
      "ec2:RegisterImage",
      "ec2:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "VmImportKmsDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "vmimport" {
  count = local.account_data.account-type == "member" ? 1 : 0

  name   = "vmimport"
  role   = aws_iam_role.vmimport[0].id
  policy = data.aws_iam_policy_document.vmimport.json
}

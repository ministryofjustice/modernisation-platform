# VM Import/Export service role required by ec2:ImportImage and ec2:ImportSnapshot.
# AWS expects this role to be named vmimport and trusted by vmie.amazonaws.com.

data "aws_iam_policy_document" "vmimport_assume_role" {
  statement {
    sid     = "AllowVmImportServiceAssumeRole"
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

  statement {
    sid     = "AllowImageBuilderExecutionAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "imagebuilder.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "vmimport_image_builder_managed_policies" {
  for_each = toset([
    "EC2InstanceProfileForImageBuilder",
    "AmazonSSMManagedInstanceCore"
  ])
  name = each.key
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

  statement {
    sid    = "VmImportImageBuilderSsmCommands"
    effect = "Allow"
    actions = [
      "ssm:SendCommand",
      "ssm:ListCommands",
      "ssm:ListCommandInvocations",
      "ssm:GetCommandInvocation"
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

resource "aws_iam_role_policy_attachment" "vmimport_image_builder_managed" {
  for_each = local.account_data.account-type == "member" ? data.aws_iam_policy.vmimport_image_builder_managed_policies : {}

  role       = aws_iam_role.vmimport[0].name
  policy_arn = each.value.arn
}

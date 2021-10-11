# Customer-managed CMK (with associated alias and key policy) used for encryption of EBS volumes and snapshots backing AMIs generated from image builder
resource "aws_kms_key" "ebs_encryption_cmk" {
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.ebs_encryption_policy_doc.json
}

resource "aws_kms_alias" "ebs_encryption_cmk_alias" {
  name          = "alias/ebs-encryption-key"
  target_key_id = aws_kms_key.ebs_encryption_cmk.id
}

data "aws_iam_policy_document" "ebs_encryption_policy_doc" {

  # checkov:skip=CKV_AWS_109: "Key policy requires asterisk resource"
  # checkov:skip=CKV_AWS_111: "Key policy requires asterisk resource"

  # Allow root users full management access to key
  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]

    resources = ["*"] # Represents the key to which this policy is attached

    principals {
      type        = "AWS"
      identifiers = concat(local.root_users_with_state_access, [data.aws_caller_identity.current.account_id])
    }

  }

  # Allow all mod platform account to use this key so that they can launch ec2 instances based on AMIs backed by encrypted snapshots
  # Actions based on https://aws.amazon.com/blogs/security/how-to-share-encrypted-amis-across-accounts-to-launch-encrypted-ec2-instances/
  # Condition based on approach taken for S3 example in https://aws.amazon.com/blogs/security/iam-share-aws-resources-groups-aws-accounts-aws-organizations/
  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:ReEncrypt*",
      "kms:CreateGrant",
      "kms:Decrypt"
    ]

    resources = ["*"]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }
  }
}

module "state-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket"
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy        = data.aws_iam_policy_document.allow-state-access-from-root-account.json
  bucket_name          = "modernisation-platform-terraform-state"
  replication_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSS3BucketReplication"
  tags                 = local.global_resources
}

# Allow access to the bucket from the MoJ root account
# Policy extrapolated from:
# https://www.terraform.io/docs/backends/types/s3.html#s3-bucket-permissions
data "aws_iam_policy_document" "allow-state-access-from-root-account" {
  statement {
    sid       = "AllowListBucketFromRootAccount"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.state-bucket.bucket.arn]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.root_account.master_account_id}:user/ModernisationPlatformOrganisationManagement"
      ]
    }
  }

  statement {
    sid    = "AllowModifyObjectsFromRootAccount"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = ["${module.state-bucket.bucket.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.root_account.master_account_id}:user/ModernisationPlatformOrganisationManagement"
      ]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.state-bucket.bucket.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.root_account.master_account_id}:user/ModernisationPlatformOrganisationManagement"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket" "modernisation-platform-terraform-state" {
  bucket = "modernisation-platform-terraform-state"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = local.global_resources
}

resource "aws_s3_bucket_public_access_block" "modernisation-platform-terraform-state" {
  bucket                  = aws_s3_bucket.modernisation-platform-terraform-state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Allow access to the bucket from the MoJ root account
# Policy extrapolated from:
# https://www.terraform.io/docs/backends/types/s3.html#s3-bucket-permissions
data "aws_iam_policy_document" "allow-access-from-root-account" {
  statement {
    sid       = "AllowListBucketFromRootAccount"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.modernisation-platform-terraform-state.arn]

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
    resources = ["${aws_s3_bucket.modernisation-platform-terraform-state.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.root_account.master_account_id}:user/ModernisationPlatformOrganisationManagement"
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.modernisation-platform-terraform-state.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.root_account.master_account_id}:user/ModernisationPlatformOrganisationManagement"
      ]
    }

    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
      values = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid     = "Require SSL"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.modernisation-platform-terraform-state.arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow-access-from-root-account" {
  bucket = aws_s3_bucket.modernisation-platform-terraform-state.id
  policy = data.aws_iam_policy_document.allow-access-from-root-account.json
}

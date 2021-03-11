data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

provider "aws" {
  alias = "eu-west-2"
  region = "eu-west-2"
}


resource "aws_s3_bucket" "acm-pca" {

  bucket_prefix ="acm"

  lifecycle {
    prevent_destroy = false
  }

  dynamic "lifecycle_rule" {
    for_each = true ? [true] : []

    content {
      enabled = true

      noncurrent_version_transition {
        days          = 30
        storage_class = "GLACIER"
      }

      transition {
        days          = 30
        storage_class = "GLACIER"
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.acm.arn
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = merge(
    local.tags,
    {
      Name = "acm-pca"
    },
  )
}


data "aws_iam_policy_document" "acmpca_bucket_access" {

    statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

     resources = [
      aws_s3_bucket.acm-pca.arn,
      "${aws_s3_bucket.acm-pca.arn}/*"
    ]
    principals {
      identifiers = ["acm-pca.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_s3_bucket_policy" "root_ca" {

  bucket = aws_s3_bucket.acm-pca.id
  policy = data.aws_iam_policy_document.acmpca_bucket_access.json

}

resource "aws_acmpca_certificate_authority" "root" {

  type = "ROOT"
  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = "moj-modernisation-platform-root-CA"
      organization = "ministry-of-justice"
      organizational_unit = "modernisation-platform"
      country = "UK"
      state = "UK"
      locality = "UK"
     }
  }
   revocation_configuration {

    crl_configuration {
      custom_cname       = "moj-modernisation-platform-crl-root-CA"
      enabled            = true
      expiration_in_days = 7
      s3_bucket_name     = aws_s3_bucket.acm-pca.id
    }
  }

   permanent_deletion_time_in_days = 7

   tags = merge(
    local.tags,
    {
      Name = "acm-pca-root-ca"
    },
  )
  depends_on = [aws_s3_bucket_policy.root_ca]
}

# # # KMS
resource "aws_kms_key" "acm" {
  description             = "ACM PCA (private certificate authority) encryption key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms-acm.json

  tags = merge(
    local.tags,
    {
      Name = "acm-pca"
    },
  )
}

resource "aws_kms_alias" "acm-alias" {
  name          = "alias/acm-pca-root"
  target_key_id = aws_kms_key.acm.arn
}

data "aws_iam_policy_document" "kms-acm" {
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["acm-pca.amazonaws.com"]
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

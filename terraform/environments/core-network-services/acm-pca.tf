data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

provider "aws" {
  alias = "eu-west-2"
  region = "eu-west-2"
}

# AWS Config: configure an S3 bucket
module "ca-bucket" {
  # source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket"
  source = "../../../../modernisation-platform-terraform-s3-bucket"
  providers = {
    aws.bucket-replication = aws.eu-west-2
  }
  bucket_policy        = data.aws_iam_policy_document.acmpca_bucket_access.json
  bucket_prefix        = "acm"
  custom_kms_key       = aws_kms_key.acm.arn
  replication_role_arn = module.s3-acm-replication-role.role.arn
  tags                 = local.tags
}

module "s3-acm-replication-role" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket-replication-role"

  buckets = [
    module.ca-bucket.bucket.arn
  ]
  suffix_name = "-acm-ca"
  tags = local.tags
}

data "aws_iam_policy_document" "acmpca_bucket_access" {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      module.ca-bucket.bucket.arn,
      "${module.ca-bucket.bucket.arn}/*"
    ]

    principals {
      identifiers = ["acm-pca.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_s3_bucket_policy" "root-ca" {
  bucket = module.ca-bucket.bucket.id
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
      s3_bucket_name     = module.ca-bucket.bucket.id
    }
  }
  permanent_deletion_time_in_days = 7

  tags = merge(
    local.tags,
    {
      Name = "acm-pca-root-ca"
    },
  )
}

# KMS
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
#   statement {
#     effect    = "Allow"
#     actions   = ["kms:*"]
#     resources = ["*"]

#     principals {
#       type        = "Service"
#       identifiers = ["acm-pca.amazonaws.com"]
#     }
#   }
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
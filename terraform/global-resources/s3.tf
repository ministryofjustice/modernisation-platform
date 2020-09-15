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
  bucket              = aws_s3_bucket.modernisation-platform-terraform-state.id
  block_public_acls   = true
  block_public_policy = true
}

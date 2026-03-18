resource "aws_s3_bucket" "replica" {
  count = local.environment == "preprod" ? 1 : 0

  bucket = "edw-19c-preprod-replica-bucket"

  tags = {
    Name        = "edw-19c-preprod-replica-bucket"
    Environment = "preproduction"
    Purpose     = "s3-replication-destination"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "replica" {
  count  = local.environment == "preprod" ? 1 : 0
  bucket = aws_s3_bucket.replica[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "replica" {
  count  = local.environment == "preprod" ? 1 : 0
  bucket = aws_s3_bucket.replica[0].id


  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



resource "aws_dynamodb_table" "state-lock" {
  name         = "modernisation-platform-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = local.tags
}

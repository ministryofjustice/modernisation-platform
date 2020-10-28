resource "aws_dynamodb_table" "state-lock" {
  name         = "modernisation-platform-terraform-state-lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.global_resources
}

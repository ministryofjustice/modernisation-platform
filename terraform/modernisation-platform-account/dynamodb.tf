resource "aws_kms_key" "dynamo_encryption" {
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.dynamo_encryption.json

  tags = merge(
    local.tags,
    {
      Name = "dynamo_encryption"
    }
  )
}

data "aws_iam_policy_document" "dynamo_encryption" {

  # checkov:skip=CKV_AWS_109: "Key policy requires asterisk resource"
  # checkov:skip=CKV_AWS_111: "Key policy requires asterisk resource"

  statement {
    effect  = "Allow"
    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["dynamodb.amazonaws.com"]
    }
  }
}

resource "aws_dynamodb_table" "state-lock" {
  name         = "modernisation-platform-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamo_encryption.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = local.tags
}

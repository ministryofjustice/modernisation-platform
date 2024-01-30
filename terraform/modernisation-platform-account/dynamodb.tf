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

resource "aws_kms_alias" "dynamo_encryption" {
  name          = "alias/dynamodb-state-lock"
  target_key_id = aws_kms_key.dynamo_encryption.id
}

resource "aws_kms_key" "dynamo_encryption_multi_region" {
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.dynamo_encryption.json
  multi_region        = true
  tags = merge(
  local.tags,
  {
    Name = "dynamo_encryption_multi_region"
  }
  )
}

resource "aws_kms_alias" "dynamo_encryption_multi_region" {
  name          = "alias/dynamodb-state-lock-multi-region"
  target_key_id = aws_kms_key.dynamo_encryption_multi_region.id
}

data "aws_iam_policy_document" "dynamo_encryption" {

  # checkov:skip=CKV_AWS_109: "Key policy requires asterisk resource"
  # checkov:skip=CKV_AWS_111: "Key policy requires asterisk resource"
  #checkov:skip=CKV_AWS_356: Policy attached to resource

  statement {
    effect  = "Allow"
    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["dynamodb.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = local.root_users_with_state_access
    }

    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id,
        aws_iam_role.modernisation_account_terraform_state.arn,
      ]
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

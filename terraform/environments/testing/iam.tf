### Testing CI user - user to be used for automated tests, access limited to the testing account and essential core resources
# Create a testing CI user
resource "aws_iam_user" "testing_ci" {
  name = "testing-ci"
  tags = local.tags
}

# Add policy directly to the testing user
data "aws_iam_policy_document" "testing_ci_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.testing_test.account_id}:role/MemberInfrastructureAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-test"]}:role/member-delegation-*-test",
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/modify-dns-records"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:Get",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/terraform.tfstate",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/members/testing/testing-test/terraform.tfstate"
    ]
  }

  # Based on https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-table-permissions
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:eu-west-2:${data.aws_caller_identity.modernisation_platform.account_id}:table/modernisation-platform-terraform-state-lock"]
  }

  # Based on https://docs.amazonaws.cn/en_us/AmazonS3/latest/userguide/UsingKMSEncryption.htm
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      "${data.aws_kms_key.s3_state_bucket.arn}",
      "${data.aws_kms_key.dynamodb_state_lock.arn}",
      "${data.aws_kms_key.environment_management.arn}",
      "${data.aws_kms_key.pagerduty.arn}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]
    resources = [
      "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.modernisation_platform.account_id}:secret:environment_management-??????",
      "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.modernisation_platform.account_id}:secret:pagerduty_integration_keys-??????"
    ]
  }
}

resource "aws_iam_policy" "testing_ci_policy" {
  name        = "TestingCiActions"
  description = "Allowed actions for the testing_ci user"
  policy      = data.aws_iam_policy_document.testing_ci_policy.json
}

resource "aws_iam_user_policy_attachment" "testing_ci_attach" {
  # checkov:skip=CKV_AWS_40: "policy is only used for this user"
  user       = aws_iam_user.testing_ci.name
  policy_arn = aws_iam_policy.testing_ci_policy.arn
}

resource "aws_iam_user_policy_attachment" "testing_ci_read_only" {
  # checkov:skip=CKV_AWS_40: "policy is only used for this user"
  user       = aws_iam_user.testing_ci.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Create access keys for the CI user
# NOTE: These are extremely sensitive keys. Do not output these anywhere publicly accessible.
resource "aws_iam_access_key" "testing_ci" {
  user = aws_iam_user.testing_ci.name

  # Setting the meta lifecycle argument allows us to periodically run `terraform taint aws_iam_access_key.ci`, and run
  # terraform apply to create new keys before these ones are destroyed.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret" "testing_ci_iam_user_keys" {
  name        = "testing_ci_iam_user_keys"
  policy      = data.aws_iam_policy_document.testing_ci_iam_user_secrets_manager_policy.json
  kms_key_id  = aws_kms_key.testing_ci_iam_user_kms_key.id
  description = "Access keys for the testing CI user, this secret is used by GitHub to set the correct repository secrets."
  tags        = local.tags
}

resource "aws_secretsmanager_secret_version" "testing_ci_iam_user_keys" {
  secret_id = aws_secretsmanager_secret.testing_ci_iam_user_keys.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.testing_ci.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.testing_ci.secret
  })
}

# KMS Source
resource "aws_kms_key" "testing_ci_iam_user_kms_key" {
  description             = "testing-ci-user-access-key"
  policy                  = data.aws_iam_policy_document.testing_ci_iam_user_kms_key_policy.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "testing_ci_iam_user_kms_key" {
  name          = "alias/testing-ci-user-access-key"
  target_key_id = aws_kms_key.testing_ci_iam_user_kms_key.id
}

data "aws_iam_policy_document" "testing_ci_iam_user_kms_key_policy" {

  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "role is resticted by limited actions in member account"

  statement {
    sid    = "AllowTestingAccount"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid    = "AllowModernisationPlatformAccount"
    effect = "Allow"
    actions = [
      "kms:Decrypt*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.modernisation_platform.id
      ]
    }
  }
}

# Secrets manager policy to share the secret to the modernisation platform account
data "aws_iam_policy_document" "testing_ci_iam_user_secrets_manager_policy" {
  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_108: "policy is directly related to the resource"
  statement {
    sid    = "AllowTestingAccount"
    effect = "Allow"
    actions = [
      "secretsmanager:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid    = "AllowModernisationPlatformAccount"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.modernisation_platform.id
      ]
    }
  }
}

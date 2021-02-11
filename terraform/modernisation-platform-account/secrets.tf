resource "aws_secretsmanager_secret" "ci_iam_user_keys" {
  name        = "ci_iam_user_keys"
  description = "Access keys for the CI user, this secret is used by GitHub to set the correct repository secrets."
  tags        = local.tags
}

resource "aws_secretsmanager_secret_version" "ci_iam_user_keys" {
  secret_id = aws_secretsmanager_secret.ci_iam_user_keys.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.ci.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.ci.secret
  })
}

resource "aws_iam_user" "email" {
  name = format("%s-%s-email_user", local.application_name, local.environment)
  tags = merge(local.tags,
    { Name = format("%s-%s-email_user", local.application_name, local.environment) }
  )
}

resource "aws_iam_access_key" "email" {
  user = aws_iam_user.email.name
}

resource "aws_iam_user_policy" "email_policy" {
  name   = format("%s-%s-email_policy", local.application_name, local.environment)
  policy = data.aws_iam_policy_document.email.json
  user   = aws_iam_user.email.name
}
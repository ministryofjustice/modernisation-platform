#tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user" "email" {
  name = format("%s-%s-email_user", local.application_name, local.environment)
  tags = merge(local.tags,
    { Name = format("%s-%s-email_user", local.application_name, local.environment) }
  )
}

resource "aws_iam_access_key" "email" {
  user = aws_iam_user.email.name
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_user_policy" "email_policy" {
  name   = "AmazonSesSendingAccess"
  user   = aws_iam_user.email.name
  policy = data.aws_iam_policy_document.email.json
}

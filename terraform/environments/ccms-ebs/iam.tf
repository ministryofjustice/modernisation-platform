#tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user" "email" {
  #checkov:skip=CKV_AWS_273: "Skipping as tfsec check is also set to ignore"
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

data "aws_iam_policy_document" "email" {
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_356: Policy follows AWS guidance
  statement {
    actions = [
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }
}
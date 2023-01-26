# Create user for MGN

#tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user" "mgn_user" {
  #checkov:skip=CKV_AWS_273: "Skipping"
  count = local.is-development == true ? 1 : 0
  name  = "MGN-Test"
  tags  = local.tags
}
#tfsec:ignore:aws-iam-user-policy-attachment
resource "aws_iam_user_policy_attachment" "mgn_attach_policy" {
  count      = local.is-development == true ? 1 : 0
  user       = aws_iam_user.mgn_user[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationFullAccess"
}

#tfsec:ignore:aws-iam-user
resource "aws_iam_user" "email" {
  #checkov:skip=CKV_AWS_273: "Skipping"
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

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "email" {
  #checkov:skip=CKV_AWS_111
  statement {
    actions = [
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }
}
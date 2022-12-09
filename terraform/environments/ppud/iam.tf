# Create user for MGN

#tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user" "mgn_user" {
  count = local.is-development == true ? 1: 0
  name = "MGN-Test"
  tags = local.tags
}

resource "aws_iam_user_policy_attachment" "mgn_attach_policy" {
	count = local.is-development == true ? 1: 0
  user       = aws_iam_user.mgn_user[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationFullAccess"
}

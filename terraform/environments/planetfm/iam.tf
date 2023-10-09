# Create user for MGN

#tfsec:ignore:aws-iam-no-user-attached-policies
#tfsec:ignore:AWS273
resource "aws_iam_user" "mgn_user" {
  #checkov:skip=CKV_AWS_273: "Skipping as tfsec check is also set to ignore"
  name = "MGN-User"
  tags = local.tags
}
#tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user_policy_attachment" "mgn_attach_policy_migration" {
  #tfsec:ignore:aws-iam-no-user-attached-policies "This is a short lived user, so allowing IAM policies attached directly to a user."
  #checkov:skip=CKV_AWS_40: "Skipping as tfsec check is also ignored"
  user       = aws_iam_user.mgn_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationAgentInstallationPolicy"
}

#tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user_policy_attachment" "mgn_attach_policy_discovery" {
  #tfsec:ignore:aws-iam-no-user-attached-policies "This is a short lived user, so allowing IAM policies attached directly to a user."
  #checkov:skip=CKV_AWS_40: "Skipping as tfsec check is also ignored"
  user       = aws_iam_user.mgn_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationDiscoveryAgentAccess"
}

resource "aws_iam_user_policy_attachment" "mgn_attach_policy_service_access" {
  #tfsec:ignore:aws-iam-no-user-attached-policies "This is a short lived user, so allowing IAM policies attached directly to a user."
  #checkov:skip=CKV_AWS_40: "Skipping as tfsec check is also ignored"
  user       = aws_iam_user.mgn_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationDiscoveryServiceFullAccess"
}

resource "aws_iam_user_policy_attachment" "mgn_attach_policy_migrationhub_access" {
  #tfsec:ignore:aws-iam-no-user-attached-policies "This is a short lived user, so allowing IAM policies attached directly to a user."
  #checkov:skip=CKV_AWS_40: "Skipping as tfsec check is also ignored"
  user       = aws_iam_user.mgn_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSMigrationHubFullAccess"
}

resource "aws_iam_user_policy_attachment" "mgn_attach_policy_app_migrationfull_access" {
  #tfsec:ignore:aws-iam-no-user-attached-policies "This is a short lived user, so allowing IAM policies attached directly to a user."
  #checkov:skip=CKV_AWS_40: "Skipping as tfsec check is also ignored"
  user       = aws_iam_user.mgn_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationFullAccess"
}

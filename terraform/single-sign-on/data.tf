# # Get AWS SSO instances. Note that this returns a list,
# # although AWS SSO only supports singular SSO instances.
data "aws_ssoadmin_instances" "default" {
  provider = aws.sso-management
}

# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  name = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

# Get AWS SSO permission sets
data "aws_ssoadmin_permission_set" "administrator" {
  provider = aws.sso-management

  instance_arn = local.sso_instance_arn
  name         = "AdministratorAccess"
}

data "aws_ssoadmin_permission_set" "view-only" {
  provider = aws.sso-management

  instance_arn = local.sso_instance_arn
  name         = "ViewOnlyAccess"
}

data "aws_ssoadmin_permission_set" "platform_engineer" {
  provider = aws.sso-management

  instance_arn = local.sso_instance_arn
  name         = "ModernisationPlatformEngineer"
}

data "aws_ssoadmin_permission_set" "security_audit" {
  provider = aws.sso-management

  instance_arn = local.sso_instance_arn
  name         = "SecurityAudit"
}

data "aws_ssoadmin_permission_set" "read_only" {
  provider = aws.sso-management

  instance_arn = local.sso_instance_arn
  name         = "ReadOnlyAccess"
}

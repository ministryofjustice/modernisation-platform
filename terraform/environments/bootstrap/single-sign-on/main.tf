# # Get AWS SSO instances. Note that this returns a list,
# # although AWS SSO only supports singular SSO instances.
data "aws_ssoadmin_instances" "default" {
  provider = aws.sso-management
}

locals {
  sso_instance_arn      = coalesce(data.aws_ssoadmin_instances.default.arns...)
  sso_identity_store_id = coalesce(data.aws_ssoadmin_instances.default.identity_store_ids...)
}

# Get AWS SSO permission sets
data "aws_ssoadmin_permission_set" "administrator" {
  provider = aws.sso-management

  instance_arn = local.sso_instance_arn
  name         = "AdministratorAccess"
}

data "aws_ssoadmin_permission_set" "read-only" {
  provider = aws.sso-management

  instance_arn = local.sso_instance_arn
  name         = "modernisation-platform-viewer"
}

# Get Identity Store groups
data "aws_identitystore_group" "platform_admin" {
  provider = aws.sso-management

  #for_each = toset(local.current-environment-definition[*].github_slug)

  identity_store_id = local.sso_identity_store_id

  filter {
    attribute_path  = "DisplayName"
    attribute_value = "modernisation-platform-engineers"
  }
}

# Get Identity Store groups
data "aws_identitystore_group" "developer" {

  count = local.sso_data[local.env_name].github_slug != "" ? 1 : 0 

  provider = aws.sso-management

  identity_store_id = local.sso_identity_store_id

  filter {
    attribute_path  = "DisplayName"
    attribute_value = try(local.sso_data[local.env_name].github_slug, null)
  }
}


resource "aws_ssoadmin_account_assignment" "platform_admin" {

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.administrator.arn

  principal_id   = data.aws_identitystore_group.platform_admin.group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}


resource "aws_ssoadmin_account_assignment" "developer" {

  count = local.sso_data[local.env_name].github_slug != "" ? 1 : 0 

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = local.sso_data[local.env_name].level == "developer" ? data.aws_ssoadmin_permission_set.read-only.arn : data.aws_ssoadmin_permission_set.read-only.arn

  principal_id   = data.aws_identitystore_group.developer[0].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

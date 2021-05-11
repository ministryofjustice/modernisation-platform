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

data "aws_ssoadmin_permission_set" "view-only" {
  provider = aws.sso-management

  instance_arn = local.sso_instance_arn
  name         = "modernisation-platform-viewer"
}

# Get Identity Store groups
data "aws_identitystore_group" "platform_admin" {
  provider = aws.sso-management

  identity_store_id = local.sso_identity_store_id

  filter {
    attribute_path  = "DisplayName"
    attribute_value = "modernisation-platform-engineers"
  }
}


# Get Identity Store groups
data "aws_identitystore_group" "developer" {

  for_each = toset(local.sso_data[local.env_name][*].github_slug)

  provider = aws.sso-management

  identity_store_id = local.sso_identity_store_id

  filter {
    attribute_path  = "DisplayName"
    attribute_value = try(each.value, null)
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

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if("${sso_assignment.level}" == "development")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.view-only.arn

  principal_id   = data.aws_identitystore_group.developer[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}


# This is only used for legacy bichard 
resource "aws_ssoadmin_account_assignment" "administator" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if("${sso_assignment.level}" == "administrator")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.administrator.arn

  principal_id   = data.aws_identitystore_group.developer[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

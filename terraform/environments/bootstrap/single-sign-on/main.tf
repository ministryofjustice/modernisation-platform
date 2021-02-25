# Get AWS SSO instances. Note that this returns a list,
# although AWS SSO only supports singular SSO instances.
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

# Get Identity Store groups
data "aws_identitystore_group" "default" {
  provider = aws.sso-management

  for_each = toset(local.current-environment-definition[*].github_slug)

  identity_store_id = local.sso_identity_store_id

  filter {
    attribute_path  = "DisplayName"
    attribute_value = each.value
  }
}

resource "aws_ssoadmin_account_assignment" "default" {
  provider = aws.sso-management

  for_each = {
    for account_assignment in local.current-environment-definition :
    "${account_assignment.account_name}-${account_assignment.github_slug}-${account_assignment.level}" => account_assignment
  }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = each.value.level == "administrator" ? data.aws_ssoadmin_permission_set.administrator.arn : data.aws_ssoadmin_permission_set.administrator.arn

  principal_id   = data.aws_identitystore_group.default[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

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
  name         = "ViewOnlyAccess"
}

data "aws_ssoadmin_permission_set" "developer" {
  provider = aws.sso-management

  instance_arn = local.sso_instance_arn
  name         = "modernisation-platform-developer"
}

# data "aws_ssoadmin_permission_set" "platform_engineer" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "ModernisationPlatformEngineer"
# }

# data "aws_ssoadmin_permission_set" "sandbox" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "modernisation-platform-sandbox"
# }

# data "aws_ssoadmin_permission_set" "migration" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "modernisation-platform-migration"
# }

# data "aws_ssoadmin_permission_set" "instance-management" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "mp-instance-management"
# }

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

# data "aws_ssoadmin_permission_set" "data_engineer" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "modernisation-platform-data-eng"
# }

# data "aws_ssoadmin_permission_set" "reporting-operations" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "mp-reporting-operations"
# }

# data "aws_ssoadmin_permission_set" "mwaa_user" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "modernisation-platform-mwaa-user"
# }

# Get Identity Store groups
data "aws_identitystore_group" "platform_admin" {
  provider = aws.sso-management

  identity_store_id = local.sso_identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "modernisation-platform-engineers"
    }
  }
}


# Get Identity Store groups
data "aws_identitystore_group" "member" {

  for_each = toset(local.sso_data[local.env_name][*].github_slug)

  provider = aws.sso-management

  identity_store_id = local.sso_identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = try(each.value, null)
    }
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

resource "aws_ssoadmin_account_assignment" "platform_engineer" {

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.platform_engineer.arn

  principal_id   = data.aws_identitystore_group.platform_admin.group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "view_only" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "view-only")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.view-only.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "developer" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "developer")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.developer.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "sandbox" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "sandbox")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.sandbox.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "migration" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "migration")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.migration.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

# This is only used for legacy bichard
resource "aws_ssoadmin_account_assignment" "administator" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "administrator")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.administrator.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "instance-management" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "instance-management")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.instance-management.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_audit" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "security-audit")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.security_audit.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "read_only" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "read-only")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.read_only.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "data_engineer" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "data-engineer")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.data_engineer.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "reporting-operations" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "reporting-operations")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.reporting-operations.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "mwaa_user" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "mwaa-user")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.mwaa_user.arn

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

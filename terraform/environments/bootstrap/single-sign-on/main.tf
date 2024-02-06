locals {
  sso_instance_arn      = coalesce(data.terraform_remote_state.mp-sso-permissions-sets.outputs.ssoadmin_instances.arns...)
  sso_identity_store_id = coalesce(data.terraform_remote_state.mp-sso-permissions-sets.outputs.ssoadmin_instances.identity_store_ids...)

}

# Get MP-specific AWS SSO permission sets

data "terraform_remote_state" "mp-sso-permissions-sets" {
  backend = "s3"
  config = {
    acl     = "bucket-owner-full-control"
    bucket  = "modernisation-platform-terraform-state"
    key     = "single-sign-on/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}


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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.administrator

  principal_id   = data.aws_identitystore_group.platform_admin.group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "platform_engineer" {

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.platform_engineer

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.view-only

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.developer

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.sandbox

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.migration

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.administrator

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.instance_management

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.security_audit

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.read_only

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.data_engineer

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.reporting_operations

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
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.mwaa_user

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "powerbi_user" {

  for_each = {

    for sso_assignment in local.sso_data[local.env_name][*] :

    "${sso_assignment.github_slug}-${sso_assignment.level}" => sso_assignment

    if(sso_assignment.level == "powerbi-user")
  }

  provider = aws.sso-management

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.terraform_remote_state.mp-sso-permissions-sets.outputs.powerbi_user

  principal_id   = data.aws_identitystore_group.member[each.value.github_slug].group_id
  principal_type = "GROUP"

  target_id   = local.environment_management.account_ids[terraform.workspace]
  target_type = "AWS_ACCOUNT"
}

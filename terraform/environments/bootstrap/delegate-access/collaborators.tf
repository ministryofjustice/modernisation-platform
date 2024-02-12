# developer role for collaborators
module "collaborator_developer_role" {
  # checkov:skip=CKV_TF_1:
  count   = local.account_data.account-type == "member" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5"
  providers = {
    aws = aws.workspace
  }
  trusted_role_arns = [
    local.modernisation_platform_account.id
  ]

  create_role       = true
  role_name         = "developer"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    aws_iam_policy.developer.arn,
  ]
  number_of_custom_role_policy_arns = 2
}

# Collaborator Sandbox role
module "collaborator_sandbox_role" {
  # checkov:skip=CKV_TF_1:
  count   = local.account_data.account-type == "member" && local.application_environment == "development" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5"
  providers = {
    aws = aws.workspace
  }
  trusted_role_arns = [
    local.modernisation_platform_account.id
  ]

  create_role       = true
  role_name         = "sandbox"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    aws_iam_policy.sandbox.arn,
  ]
  number_of_custom_role_policy_arns = 2
}

module "collaborator_database_mgmt_role" {
  # checkov:skip=CKV_TF_1:
  count   = local.account_data.account-type == "member" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5"
  providers = {
    aws = aws.workspace
  }
  trusted_role_arns = [
    local.modernisation_platform_account.id
  ]

  create_role       = true
  role_name         = "instance-management"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    aws_iam_policy.instance-management.arn,
  ]
  number_of_custom_role_policy_arns = 2
}
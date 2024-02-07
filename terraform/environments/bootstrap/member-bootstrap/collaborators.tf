data "aws_iam_policy" "fleet_manager" {
  name = "fleet_manager_policy"
}

# fleet-manager role for collaborators
module "collaborator_fleet_manager_role" {
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
  role_name         = "fleet-manager"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    data.aws_iam_policy.fleet_manager.arn
  ]
  number_of_custom_role_policy_arns = 2
}
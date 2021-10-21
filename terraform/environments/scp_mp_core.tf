#  Modernisation Platform Core ou SCP policy
data "aws_iam_policy_document" "scp_mp_core_ou" {
  #checkov:skip=CKV_AWS_1:Policy applied to a limited number of accounts
  #checkov:skip=CKV_AWS_49:Policy applied to a limited number of accounts
  #checkov:skip=CKV_AWS_107:Policy applied to a limited number of accounts
  #checkov:skip=CKV_AWS_108:Policy applied to a limited number of accounts
  #checkov:skip=CKV_AWS_109:Policy applied to a limited number of accounts
  #checkov:skip=CKV_AWS_110:Policy applied to a limited number of accounts
  #checkov:skip=CKV_AWS_111:Policy applied to a limited number of accounts
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

# Separate policy for preventing root access (so it can be detached separately if need be)
data "aws_iam_policy_document" "scp_mp_core_ou_prevent_root" {
  version = "2012-10-17"

  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.modernisation_platform_ou_id}/*"]
    }
    # For testing this against a specific account, follow this method
    # condition {
    #   test     = "ForAnyValue:StringLike"
    #   variable = "aws:PrincipalOrgPaths"
    #   values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.modernisation_platform_ou_id}/*/<member ou id>/*"] 
    # } 
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

# This policy will only be applied to accounts within the "Modernisation Platform Core" ou
# The default policy
resource "aws_organizations_policy" "scp_mp_core_ou" {
  name        = "Modernisation Platform Core OU SCP"
  description = "Restricts permissions for all OUs and accounts under the Modernisation Platform Core OU"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.scp_mp_core_ou.json

  tags = {
    business-unit = "Platforms"
    component     = "SERVICE_CONTROL_POLICY"
    source-code   = local.github_repository
  }
}

# The policy preventing root access
resource "aws_organizations_policy" "scp_mp_core_ou_prevent_root" {
  name        = "Modernisation Platform Core OU SCP - Prevent Root"
  description = "Prevents root user access for all OUs and accounts under the Modernisation Platform Core OU"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.scp_mp_core_ou_prevent_root.json

  tags = {
    business-unit = "Platforms"
    component     = "SERVICE_CONTROL_POLICY"
    source-code   = local.github_repository
  }
}

# Enrol all accounts within the Modernisation Platform Core OU (current and future) to the Modernisation Platform Core OU SCP
# The policy attachment for the default policy
resource "aws_organizations_policy_attachment" "scp_mp_core_ou" {
  policy_id = aws_organizations_policy.scp_mp_core_ou.id
  target_id = module.environments.modernisation_platform_core_ou_id
}

# The policy attachment for the policy preventing root access
resource "aws_organizations_policy_attachment" "scp_mp_core_ou_prevent_root" {
  policy_id = aws_organizations_policy.scp_mp_core_ou_prevent_root.id
  target_id = module.environments.modernisation_platform_core_ou_id
}

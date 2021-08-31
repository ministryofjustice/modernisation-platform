#  Modernisation Platform Member Unrestriced ou SCP policy
data "aws_iam_policy_document" "scp_mp_member_unrestriced_ou" {
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

# This policy will only be applied to accounts withing the "Modernisation Platform Member Unrestriced" ou
resource "aws_organizations_policy" "scp_mp_member_unrestriced_ou" {
  name        = "Modernisation Platform Member Unrestriced OU SCP"
  description = "Restricts permissions for all OUs and accounts under the Modernisation Platform Member Unrestriced OU"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.scp_mp_member_unrestriced_ou.json

  tags = {
    business-unit = "Platforms"
    component     = "SERVICE_CONTROL_POLICY"
    source-code   = local.github_repository
  }
}

# Enrol all accounts within the Modernisation Platform Member Unrestriced OU (current and future) to the Modernisation Platform Member Unrestriced OU SCP
resource "aws_organizations_policy_attachment" "scp_mp_member_unrestriced_ou" {
  policy_id = aws_organizations_policy.scp_mp_member_unrestriced_ou.id
  target_id = module.environments.modernisation_platform_member_unrestricted_ou_id
}

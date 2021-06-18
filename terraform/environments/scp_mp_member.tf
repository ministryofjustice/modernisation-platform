#  Modernisation Platform Member ou SCP policy
data "aws_iam_policy_document" "scp_mp_member_ou" {
  version = "2012-10-17"

  statement {
    effect = "Deny"
    actions = [
      "ec2:CreateVpc",
      "ec2:CreateSubnet",
      "ec2:CreateVpcPeeringConnection"
    ]
    resources = ["*"]
  }
}

# This policy will only be applied to accounts within the "Modernisation Platform Member" ou
resource "aws_organizations_policy" "scp_mp_member_ou" {
  name        = "Modernisation Platform Member OU SCP"
  description = "Restricts permissions for all OUs and accounts under the Modernisation Platform Member OU"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.scp_mp_member_ou.json

  tags = {
    business-unit = "Platforms"
    component     = "SERVICE_CONTROL_POLICY"
    source-code   = local.github_repository
  }
}

# Enrol all accounts within the Modernisation Platform Member OU (current and future) to the Modernisation Platform Member OU SCP
resource "aws_organizations_policy_attachment" "scp_mp_member_ou" {
  policy_id = aws_organizations_policy.scp_mp_member_ou.id
  target_id = module.environments.modernisation_platform_member_ou_id
}

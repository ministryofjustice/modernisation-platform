locals {


  account_name = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, regex("-[^-]*$", terraform.workspace), ""))


  account_data = jsondecode(file("../../../../environments/${local.account_name}.json"))

}

module "cross-account-access" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=v2.0.0"
  providers = {
    aws = aws.workspace
  }
  account_id = local.modernisation_platform_account.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role_name  = "ModernisationPlatformAccess"
}

module "cicd-member-user" {

  count = local.account_data.account-type == "member" ? 1 : 0

  source = "../../../modules/iam_baseline"

  providers = {
    aws = aws.workspace
  }
}

module "member-access" {
  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=v2.0.0"
  providers = {
    aws = aws.workspace
  }
  account_id = local.modernisation_platform_account.id
  policy_arn = aws_iam_policy.member-access[0].id
  role_name  = "MemberInfrastructureAccess"
}

data "aws_iam_policy_document" "member-access" {
  statement {
    #checkov:skip=CKV_AWS_108
    #checkov:skip=CKV_AWS_111
    #checkov:skip=CKV_AWS_107
    #checkov:skip=CKV_AWS_109
    #checkov:skip=CKV_AWS_110
    effect = "Allow"
    actions = [ #tfsec:ignore:AWS099
      "acm-pca:*",
      "acm:*",
      "application-autoscaling:*",
      "autoscaling:*",
      "cloudfront:*",
      "cloudwatch:*",
      "dynamodb:*",
      "ebs:*",
      "ec2:*",
      "ecr-public:*",
      "ecr:*",
      "ecs:*",
      "elasticfilesystem:*",
      "elasticloadbalancing:*",
      "glacier:*",
      "guardduty:get*",
      "iam:*",
      "kms:*",
      "lambda:*",
      "logs:*",
      "organizations:Describe*",
      "organizations:List*",
      "rds-db:*",
      "rds:*",
      "route53:*",
      "s3:*",
      "secretsmanager:*",
      "ses:*",
      "sns:*",
      "sqs:*",
      "ssm:*",
      "sts:*"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }

  statement {
    effect = "Deny"
    actions = [
      "ec2:CreateVpc",
      "ec2:CreateSubnet",
      "ec2:CreateVpcPeeringConnection",
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:AddUserToGroup",
      "iam:AttachGroupPolicy",
      "iam:AttachUserPolicy",
      "iam:CreateAccountAlias",
      "iam:CreateGroup",
      "iam:CreateLoginProfile",
      "iam:CreateOpenIDConnectProvider",
      "iam:CreateSAMLProvider",
      "iam:CreateUser",
      "iam:CreateVirtualMFADevice",
      "iam:DeactivateMFADevice",
      "iam:DeleteAccountAlias",
      "iam:DeleteAccountPasswordPolicy",
      "iam:DeleteGroup",
      "iam:DeleteGroupPolicy",
      "iam:DeleteLoginProfile",
      "iam:DeleteOpenIDConnectProvider",
      "iam:DeleteSAMLProvider",
      "iam:DeleteUser",
      "iam:DeleteUserPermissionsBoundary",
      "iam:DeleteUserPolicy",
      "iam:DeleteVirtualMFADevice",
      "iam:DetachGroupPolicy",
      "iam:DetachUserPolicy",
      "iam:EnableMFADevice",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:RemoveUserFromGroup",
      "iam:ResyncMFADevice",
      "iam:UpdateAccountPasswordPolicy",
      "iam:UpdateGroup",
      "iam:UpdateLoginProfile",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:UpdateSAMLProvider",
      "iam:UpdateUser"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "member-access" {
  count    = local.account_data.account-type == "member" ? 1 : 0
  provider = aws.workspace

  name        = "MemberInfrastructureAccessActions"
  description = "Restricted admin policy for member CI/CD to use"
  policy      = data.aws_iam_policy_document.member-access.json
}

# Create a parameter for the modernisation platform environment management secret ARN that can be used to gain
# access to the environments parameter when running a tf plan locally

resource "aws_ssm_parameter" "environment_management_arn" {
  provider = aws.workspace

  name  = "environment_management_arn"
  type  = "SecureString"
  value = data.aws_secretsmanager_secret.environment_management.arn

  tags = local.environments
}

locals {
  account_name = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, regex("-[^-]*$", terraform.workspace), ""))
  account_data = jsondecode(file("../../../../environments/${local.account_name}.json"))
}

resource "aws_iam_account_alias" "alias" {
  count         = (local.account_data.account-type != "member-unrestricted") && !(contains(local.skip_alias, terraform.workspace)) ? 1 : 0
  provider      = aws.workspace
  account_alias = terraform.workspace
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

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "member-access" {
  statement {
    #checkov:skip=CKV_AWS_108
    #checkov:skip=CKV_AWS_111
    #checkov:skip=CKV_AWS_107
    #checkov:skip=CKV_AWS_109
    #checkov:skip=CKV_AWS_110
    effect = "Allow"
    actions = [
      "acm-pca:*",
      "acm:*",
      "application-autoscaling:*",
      "athena:*",
      "autoscaling:*",
      "cloudfront:*",
      "cloudwatch:*",
      "dlm:*",
      "dynamodb:*",
      "ebs:*",
      "ec2:Describe*",
      "ec2:*SecurityGroup*",
      "ec2:*KeyPair*",
      "ec2:*Tags*",
      "ec2:*Volume*",
      "ec2:*Snapshot*",
      "ec2:*Ebs*",
      "ec2:*NetworkInterface*",
      "ec2:*Address*",
      "ec2:*Image*",
      "ec2:*Event*",
      "ec2:*Instance*",
      "ec2:*CapacityReservation*",
      "ec2:*Fleet*",
      "ec2:Get*",
      "ec2:SendDiagnosticInterrupt",
      "ec2:*LaunchTemplate*",
      "ec2:*PlacementGroup*",
      "ec2:*IdFormat*",
      "ec2:*Spot*",
      "ecr-public:*",
      "ecr:*",
      "ecs:*",
      "elasticfilesystem:*",
      "elasticloadbalancing:*",
      "events:*",
      "glacier:*",
      "glue:*",
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
      "wafv2:*"
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

  statement {
    effect = "Deny"
    actions = [
      "iam:AttachRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteRolePermissionsBoundary",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription"
    ]
    resources = ["arn:aws:iam::*:user/cicd-member-user"]
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

# read only role for collaborators
module "collaborator_readonly_role" {
  count   = local.account_data.account-type == "member" || local.account_data.account-type == "core" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles"
  version = "~> 5.11"
  providers = {
    aws = aws.workspace
  }
  max_session_duration = 43200

  # Read-only role
  create_readonly_role       = true
  readonly_role_name         = "read-only"
  readonly_role_requires_mfa = true

  # Allow created users to assume these roles
  trusted_role_arns = [
    local.modernisation_platform_account.id
  ]
}

# security audit role for collaborators
module "collaborator_security_audit_role" {
  count   = local.account_data.account-type == "member" || local.account_data.account-type == "core" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4"
  providers = {
    aws = aws.workspace
  }
  max_session_duration = 43200

  create_role       = true
  role_name         = "security-audit"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/SecurityAudit"
  ]

  # Allow created users to assume these roles
  trusted_role_arns = [
    local.modernisation_platform_account.id
  ]
}

# developer role for collaborators
module "collaborator_developer_role" {
  count   = local.account_data.account-type == "member" || local.account_data.account-type == "core" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4"
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
    aws_iam_policy.developer[count.index].arn,
  ]
  number_of_custom_role_policy_arns = 2
}

resource "aws_iam_policy" "developer" {
  count    = local.account_data.account-type == "member" || local.account_data.account-type == "core" ? 1 : 0
  provider = aws.workspace
  name     = "developer_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.developer-additional.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "developer-additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_111
  statement {
    actions = [
      "acm:ImportCertificate",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:RestoreSecret",
      "ssm:*",
      "ssm-guiconnect:*",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:RebootInstances",
      "ec2:CreateImage",
      "ec2:CopySnapshot",
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:CreateTags",
      "s3:PutObject",
      "s3:DeleteObject",
      "aws-marketplace:ViewSubscriptions",
      "support:*"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "sns:Publish"
    ]

    resources = ["arn:aws:sns:*:*:Automation*"]
  }

  statement {
    actions = [
      "lambda:InvokeFunction"
    ]

    resources = ["arn:aws:lambda:*:*:function:Automation*"]
  }

  statement {
    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:GetUser",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey"
    ]

    resources = ["arn:aws:iam::*:user/cicd-member-user"]
  }
}

# AWS Shield Advanced SRT (Shield Response Team) support role
module "shield_response_team_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4"
  providers = {
    aws = aws.workspace
  }
  trusted_role_services = ["drt.shield.amazonaws.com"]

  create_role       = true
  role_name         = "AWSSRTSupport"
  role_requires_mfa = false

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSShieldDRTAccessPolicy"]

  number_of_custom_role_policy_arns = 1
}

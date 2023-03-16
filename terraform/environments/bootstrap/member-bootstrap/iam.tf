locals {
  account_name = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, regex("-[^-]*$", terraform.workspace), ""))
  account_data = jsondecode(file("../../../../environments/${local.account_name}.json"))
}

module "member-access" {
  count                  = local.account_data.account-type == "member" && terraform.workspace != "testing-test" ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=v2.3.0"
  account_id             = local.modernisation_platform_account.id
  additional_trust_roles = [one(data.aws_iam_roles.github_actions_role.arns), one(data.aws_iam_roles.member-sso-admin-access.arns)]
  policy_arn             = aws_iam_policy.member-access[0].id
  role_name              = "MemberInfrastructureAccess"
}

# lots of SCA ignores and skips on this one as it is the main role allowing members to build most things in the platform
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "member-access" {
  statement {
    #checkov:skip=CKV_AWS_108
    #checkov:skip=CKV_AWS_111
    #checkov:skip=CKV_AWS_107
    #checkov:skip=CKV_AWS_109
    #checkov:skip=CKV_AWS_110
    #checkov:skip=CKV2_AWS_40
    effect = "Allow"
    actions = [
      "acm-pca:*",
      "acm:*",
      "application-autoscaling:*",
      "applicationinsights:*",
      "athena:*",
      "autoscaling:*",
      "backup:*",
      "cloudfront:*",
      "cloudwatch:*",
      "codebuild:*",
      "codedeploy:*",
      "codepipeline:*",
      "dbqms:*",
      "dlm:*",
      "dms:*",
      "ds:CheckAlias",
      "ds:Describe*",
      "ds:List*",
      "ds:*Tags*",
      "ds:CancelSchemaExtension",
      "ds:CreateComputer",
      "ds:CreateAlias",
      "ds:CreateDirectory",
      "ds:CreateLogSubscription",
      "ds:CreateMicrosoftAD",
      "ds:CreateSnapshot",
      "ds:DeleteDirectory",
      "ds:DeleteLogSubscription",
      "ds:DeleteSnapshot",
      "ds:DeregisterCertificate",
      "ds:DeregisterEventTopic",
      "ds:DisableClientAuthentication",
      "ds:DisableLDAPS",
      "ds:DisableRadius",
      "ds:EnableClientAuthentication",
      "ds:EnableLDAPS",
      "ds:EnableRadius",
      "ds:RegisterCertificate",
      "ds:RegisterEventTopic",
      "ds:ResetUserPassword",
      "ds:RestoreFromSnapshot",
      "ds:StartSchemaExtension",
      "ds:UpdateDirectorySetup",
      "ds:UpdateNumberOfDomainControllers",
      "ds:UpdateRadius",
      "ds:UpdateSettings",
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
      "firehose:*",
      "glacier:*",
      "glue:*",
      "guardduty:get*",
      "iam:*",
      "kinesis:*",
      "kms:*",
      "lambda:*",
      "logs:*",
      "organizations:Describe*",
      "organizations:List*",
      "quicksight:*",
      "rds-db:*",
      "rds:*",
      "rds-data:*",
      "route53:*",
      "s3:*",
      "secretsmanager:*",
      "ses:*",
      "sns:*",
      "sqs:*",
      "ssm:*",
      "waf:*",
      "wafv2:*",
      "resource-groups:*",
      "redshift:*",
      "redshift-data:*",
      "redshift-serverless:*"
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
  count       = local.account_data.account-type == "member" ? 1 : 0
  name        = "MemberInfrastructureAccessActions"
  description = "Restricted admin policy for member CI/CD to use"
  policy      = data.aws_iam_policy_document.member-access.json
}

# Testing-test member access - separate as need the testing user created in the testing account to be able to access as well
data "aws_iam_policy_document" "assume_role_policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${local.modernisation_platform_account.id}:root",
        "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:user/testing-ci",
        one(data.aws_iam_roles.member-sso-admin-access.arns)
      ]
    }
  }
}

# IAM role to be assumed
resource "aws_iam_role" "testing_member_infrastructure_access_role" {
  count              = terraform.workspace == "testing-test" ? 1 : 0
  name               = "MemberInfrastructureAccess"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# IAM role attached policy
resource "aws_iam_role_policy_attachment" "testing_member_infrastructure_access_role" {
  count      = terraform.workspace == "testing-test" ? 1 : 0
  role       = aws_iam_role.testing_member_infrastructure_access_role[0].id
  policy_arn = aws_iam_policy.member-access[0].arn
}

# MemberInfrastructureAccessUSEast
module "member-access-us-east" {
  count                  = local.account_data.account-type == "member" && terraform.workspace != "testing-test" ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=v2.3.0"
  account_id             = local.modernisation_platform_account.id
  additional_trust_roles = [one(data.aws_iam_roles.github_actions_role.arns), one(data.aws_iam_roles.member-sso-admin-access.arns)]
  policy_arn             = aws_iam_policy.member-access-us-east[0].id
  role_name              = "MemberInfrastructureAccessUSEast"
}

# lots of SCA ignores and skips on this one as it is the main role allowing members to build most things in the platform
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "member-access-us-east" {
  statement {
    #checkov:skip=CKV_AWS_108
    #checkov:skip=CKV_AWS_111
    #checkov:skip=CKV_AWS_107
    #checkov:skip=CKV_AWS_109
    #checkov:skip=CKV_AWS_110
    #checkov:skip=CKV2_AWS_40
    effect = "Allow"
    actions = [
      "acm:*"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }

  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "member-access-us-east" {
  count       = local.account_data.account-type == "member" ? 1 : 0
  name        = "MemberInfrastructureAccessUSEastActions"
  description = "Restricted policy for US East usage"
  policy      = data.aws_iam_policy_document.member-access-us-east.json
}


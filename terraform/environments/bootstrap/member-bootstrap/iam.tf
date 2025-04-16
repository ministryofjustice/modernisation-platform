locals {
  account_name = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, regex("-[^-]*$", terraform.workspace), ""))
  account_data = jsondecode(file("../../../../environments/${local.account_name}.json"))
}

module "member-access" {
  count                  = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=6819b090bce6d3068d55c7c7b9b3fd18c9dca648" #v3.0.0
  account_id             = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = [module.github-oidc[0].github_actions_role, one(data.aws_iam_roles.member-sso-admin-access.arns)]
  policy_arn             = aws_iam_policy.member-access[0].id
  role_name              = "MemberInfrastructureAccess"
}

module "member-access-sprinkler" {
  count                  = (terraform.workspace == "sprinkler-development") ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=6819b090bce6d3068d55c7c7b9b3fd18c9dca648" #v3.0.0
  account_id             = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = [data.aws_iam_role.sprinkler_oidc[0].arn, one(data.aws_iam_roles.member-sso-admin-access.arns)]
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
    #checkov:skip=CKV_AWS_356: Needs to access multiple resources
    effect = "Allow"
    actions = [
      "acm-pca:*",
      "acm:*",
      "airflow:*",
      "apigateway:*",
      "application-autoscaling:*",
      "applicationinsights:*",
      "aps:*",
      "aoss:*",
      "athena:*",
      "autoscaling:*",
      "backup:*",
      "backup-storage:MountCapsule",
      "bcm-data-exports:*",
      "bedrock:*",
      "chatbot:*",
      "cloudformation:*",
      "cloudfront:*",
      "cloudwatch:*",
      "cloudtrail:AddTags",
      "cloudtrail:CancelQuery",
      "cloudtrail:Create*",
      "cloudtrail:StartLogging",
      "cloudtrail:PutEventSelectors",
      "cloudtrail:DescribeTrails",
      "cloudtrail:Get*",
      "cloudtrail:List*",
      "codebuild:*",
      "codedeploy:*",
      "codepipeline:*",
      "cognito-idp:*",
      "cur:DeleteReportDefinition",
      "cur:DescribeReportDefinitions",
      "cur:ListTagsForResource",
      "cur:PutReportDefinition",
      "datasync:*",
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
      "ds:Delete*",
      "ds:Deregister*",
      "ds:Disable*",
      "ds:Enable*",
      "ds:RegisterCertificate",
      "ds:RegisterEventTopic",
      "ds:ResetUserPassword",
      "ds:RestoreFromSnapshot",
      "ds:StartSchemaExtension",
      "ds:Update*",
      "ds-data:*",
      "dynamodb:*",
      "ebs:*",
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:*RouteTable*",
      "ec2:CreateVpcEndpoint",
      "ec2:DeleteVpcEndpoints",
      "ec2:CreateVpcEndpointServiceConfiguration",
      "ec2:DeleteVpcEndpointServiceConfigurations",
      "ec2:DisableSerialConsoleAccess",
      "ec2:EnableSerialConsoleAccess",
      "ec2:GetSerialConsoleAccessStatus",
      "ec2:ModifyVpc*",
      "ec2:Describe*",
      "ec2:*NetworkAcl*",
      "ec2:*FlowLogs",
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
      "ec2:*InternetGateway*",
      "ec2:*NatGateway*",
      "ec2:*TransitGatewayVpcAttachment*",
      "ecr-public:*",
      "ecr:*",
      "ecs:*",
      "elasticache:*",
      "elasticfilesystem:*",
      "elasticloadbalancing:*",
      "eks:*",
      "es:*",
      "events:*",
      "fsx:*",
      "firehose:*",
      "glacier:*",
      "glue:*",
      "grafana:*",
      "guardduty:get*",
      "iam:*",
      "kinesis:*",
      "kms:*",
      "lakeformation:*",
      "lambda:*",
      "logs:*",
      "organizations:Describe*",
      "organizations:List*",
      "oam:*",
      "quicksight:*",
      "ram:AssociateResourceShare",
      "ram:CreateResourceShare",
      "ram:DeleteResourceShare",
      "ram:Get*",
      "ram:List*",
      "rds-db:*",
      "rds:*",
      "rds-data:*",
      "route53:*",
      "route53resolver:*",
      "s3:*",
      "scheduler:*",
      "secretsmanager:*",
      "ses:*",
      "shield:*",
      "signer:*",
      "sns:*",
      "sqs:*",
      "ssm:*",
      "sso:CreateApplicationAssignment",
      "sso:DeleteApplicationAssignment",
      "sso:DescribeApplicationAssignment",
      "sso:DescribeRegisteredRegions",
      "sso:GetApplicationAssignmentConfiguration",
      "sso:GetSharedSsoConfiguration",
      "sso:ListApplicationAssignments",
      "sso:ListApplicationAssignmentsForPrincipal",
      "sso:ListDirectoryAssociations",
      "sso:GetManagedApplicationInstance",
      "sso:ListProfiles",
      "sso:AssociateProfile",
      "sso:DisassociateProfile",
      "sso:GetProfile",
      "sso:CreateApplication",
      "sso:ListInstances",
      "sso:DeleteApplication",
      "sso:PutApplicationAssignmentConfiguration",
      "sso:PutApplicationGrant",
      "sso:PutApplicationAuthenticationMethod",
      "sso:ListProfileAssociations",
      "sso-directory:DescribeUser",
      "sso-directory:DescribeGroup",
      "states:*",
      "synthetics:*",
      "waf:*",
      "wafv2:*",
      "resource-groups:*",
      "redshift:*",
      "redshift-data:*",
      "redshift-serverless:*",
      "resource-explorer-2:*",
      "transfer:*",
      "kinesisanalytics:*Application*",
      "kinesisanalytics:*Resource",
      "sagemaker:*"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }
  statement {
    effect    = "Allow"
    actions   = ["cloudtrail:DeleteTrail"]
    resources = ["arn:aws:cloudtrail:*:*:trail/cloudtrail-test*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values = [
        local.environment_management.account_ids["testing-test"]
      ]
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:DeleteObject"]
    resources = ["arn:aws:s3:::cloudtrail-test*/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values = [
        local.environment_management.account_ids["testing-test"]
      ]
    }
  }
  statement {
    sid    = "GuardDutyMalwareProtectionActions"
    effect = "Allow"
    actions = [
      "guardduty:CreateMalwareProtectionPlan",
      "guardduty:DeleteMalwareProtectionPlan",
      "guardduty:ListDetectors",
      "guardduty:ListTagsForResource",
      "guardduty:TagResource",
      "guardduty:UpdateMalwareProtectionPlan"
    ]
    resources = [
      "arn:aws:guardduty:eu-west-2:*:malware-protection-plan/*"
    ]
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:CalledVia"
      values   = ["guardduty.amazonaws.com"]
    }
  }
  statement {
    effect = "Deny"
    actions = [
      "ec2:CreateVpcPeeringConnection",
      "iam:AddUserToGroup",
      "iam:AttachGroupPolicy",
      "iam:CreateAccountAlias",
      "iam:CreateGroup",
      "iam:CreateLoginProfile",
      "iam:CreateSAMLProvider",
      "iam:CreateVirtualMFADevice",
      "iam:DeactivateMFADevice",
      "iam:DeleteAccountAlias",
      "iam:DeleteAccountPasswordPolicy",
      "iam:DeleteGroup",
      "iam:DeleteGroupPolicy",
      "iam:DeleteLoginProfile",
      "iam:DeleteSAMLProvider",
      "iam:DeleteUserPermissionsBoundary",
      "iam:DeleteVirtualMFADevice",
      "iam:DetachGroupPolicy",
      "iam:EnableMFADevice",
      "iam:RemoveUserFromGroup",
      "iam:ResyncMFADevice",
      "iam:UpdateAccountPasswordPolicy",
      "iam:UpdateGroup",
      "iam:UpdateLoginProfile",
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
  statement {
    actions = ["iam:PassRole"]
    effect  = "Deny"
    resources = [
      "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/GuardDutyS3MalwareProtectionRole"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "iam:PassedToService"
      values = [
        "malware-protection-plan.guardduty.amazonaws.com"
      ]
    }
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
      identifiers = ["arn:aws:iam::${data.aws_ssm_parameter.modernisation_platform_account_id.value}:root",
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
  count                  = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=6819b090bce6d3068d55c7c7b9b3fd18c9dca648" #v3.0.0
  account_id             = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = [module.github-oidc[0].github_actions_role, one(data.aws_iam_roles.member-sso-admin-access.arns)]
  policy_arn             = aws_iam_policy.member-access-us-east[0].id
  role_name              = "MemberInfrastructureAccessUSEast"
}

module "member-access-us-east-sprinkler" {
  count                  = (terraform.workspace == "sprinkler-development") ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=6819b090bce6d3068d55c7c7b9b3fd18c9dca648" #v3.0.0
  account_id             = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = [data.aws_iam_role.sprinkler_oidc[0].arn, one(data.aws_iam_roles.member-sso-admin-access.arns)]
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
    #checkov:skip=CKV_AWS_356: Needs to access multiple resources
    effect = "Allow"
    actions = ["acm:*",
      "logs:*",
      "waf:*",
      "wafv2:*",
      "cur:PutReportDefinition",
      "cur:DeleteReportDefinition",
      "cur:ModifyReportDefinition",
      "cur:DescribeReportDefinitions"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }
  statement {
    effect = "Deny"
    actions = [
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
    actions   = ["iam:PassRole"]
    effect    = "Deny"
    resources = ["arn:aws:iam::*:role/MemberInfrastructureAccessUSEast"]
  }
}

resource "aws_iam_policy" "member-access-us-east" {
  count       = local.account_data.account-type == "member" ? 1 : 0
  name        = "MemberInfrastructureAccessUSEastActions"
  description = "Restricted policy for US East usage"
  policy      = data.aws_iam_policy_document.member-access-us-east.json
}

# Github OIDC role
module "github_oidc_role" {
  count                = length(compact(jsondecode(data.http.environments_file.response_body).github-oidc-team-repositories)) > 0 ? 1 : 0
  source               = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=62b8a16c73d8e4422cd81923e46948e8f4b5cf48" # v3.2.0
  github_repositories  = jsondecode(data.http.environments_file.response_body).github-oidc-team-repositories
  max_session_duration = 21600
  role_name            = "modernisation-platform-oidc-cicd"
  policy_jsons         = [data.aws_iam_policy_document.policy.json]
  tags                 = local.tags
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "policy" {
  #checkov:skip=CKV_AWS_289
  #checkov:skip=CKV_AWS_288
  #checkov:skip=CKV_AWS_290
  #checkov:skip=CKV_AWS_355: Allows access to multiple unknown resources
  statement {
    #checkov:skip=CKV_AWS_108
    #checkov:skip=CKV_AWS_111
    #checkov:skip=CKV_AWS_107
    #checkov:skip=CKV_AWS_109
    #checkov:skip=CKV_AWS_110
    #checkov:skip=CKV2_AWS_40
    #checkov:skip=CKV_AWS_356: Needs to access multiple resources
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "autoscaling:PutScheduledUpdateGroupAction",
      "autoscaling:SetDesiredCapacity",
      "backup:*",
      "cloudwatch:PutMetricData",
      "codebuild:Start*",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds",
      "codepipeline:StartPipelineExecution",
      "datasync:Create*",
      "datasync:Delete*",
      "datasync:Describe*",
      "datasync:List*",
      "datasync:StartTaskExecution",
      "datasync:*Tag*",
      "dms:StartReplicationTask",
      "dms:StopReplicationTask",
      "dms:TestConnection",
      "dms:StartReplicationTaskAssessment",
      "dms:StartReplicationTaskAssessmentRun",
      "dms:DescribeEndpoints",
      "dms:DescribeEndpointSettings",
      "dms:*Certificate",
      "dms:ModifyEndpoint",
      "dms:RebootReplicationInstance",
      "ds:AccessDSData",
      "ds:DescribeDirectories",
      "ds:EnableDirectoryDataAccess",
      "ds:ResetUserPassword",
      "ds-data:*",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "ecs:ExecuteCommand",
      "ecs:*Service*",
      "ecs:*Task*",
      "ecs:*Tag*",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ec2:DescribeInstances",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:AttachNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DeregisterImage",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeNetworkInterfaces",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "elasticfilesystem:Describe*",
      "elasticfilesystem:Create*",
      "elasticfilesystem:Delete*",
      "elasticfilesystem:restore",
      "elasticloadbalancing:SetRulePriorities",
      "elasticloadbalancing:ModifyRule",
      "glue:GetJobRuns",
      "glue:StartJobRun",
      "glue:GetJobs",
      "glue:GetTable",
      "glue:BatchGetJobs",
      "glue:ListJobs",
      "glue:StartJobRun",
      "glue:StartTrigger",
      "glue:StopSession",
      "glue:StopTrigger",
      "glue:BatchStopJobRun",
      "glue:StopWorkflowRun",
      "glue:UpdateJob",
      "iam:getRole",
      "iam:getRolePolicy",
      "iam:listAttachedRolePolicies",
      "iam:listInstanceProfilesForRole",
      "iam:listRolePolicies",
      "iam:ListRoles",
      "kinesis:PutRecord",
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "lambda:GetCodeSigningConfig",
      "lambda:UpdateFunctionCode",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:DescribeResourcePolicies",
      "logs:GetLogEvents",
      "rds:*Tag*",
      "rds:*Snapshot*",
      "rds:StartDBInstance",
      "rds:StopDBInstance",
      "route53:ChangeResourceRecordSets",
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:*Object*",
      "s3:*Tag*",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecrets",
      "secretsmanager:PutSecretValue",
      "secretsmanager:RotateSecret",
      "secretsmanager:UpdateSecretVersionStage",
      "ses:*SuppressedDestination",
      "ssm:GetParameter",
      "ssm:PutParameter",
      "ssm:DescribeSessions",
      "ssm:ResumeSession",
      "ssm:SendCommand",
      "ssm:StartSession",
      "ssm:TerminateSession"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }

  statement {
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = ["ssm.amazonaws.com", "ecs.amazonaws.com", "ecs-tasks.amazonaws.com","backup.amazonaws.com"]
      variable = "iam:PassedToService"
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant"
    ]

    resources = [
      "arn:aws:kms:eu-west-2:${local.environment_management.account_ids["core-shared-services-production"]}:key/*",
      "arn:aws:kms:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-development"]}:key/*",
      "arn:aws:kms:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-test"]}:key/*",
      "arn:aws:kms:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-production"]}:key/*"
    ]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

# MemberInfrastructureBedrockEuCentral
module "member-access-eu-central" {
  count                  = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=6819b090bce6d3068d55c7c7b9b3fd18c9dca648" #v3.0.0
  account_id             = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = [module.github-oidc[0].github_actions_role, one(data.aws_iam_roles.member-sso-admin-access.arns)]
  policy_arn             = aws_iam_policy.member-access-eu-central[0].id
  role_name              = "MemberInfrastructureBedrockEuCentral"
}

module "member-access-eu-central-sprinkler" {
  count                  = (terraform.workspace == "sprinkler-development") ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=6819b090bce6d3068d55c7c7b9b3fd18c9dca648" #v3.0.0
  account_id             = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = [data.aws_iam_role.sprinkler_oidc[0].arn, one(data.aws_iam_roles.member-sso-admin-access.arns)]
  policy_arn             = aws_iam_policy.member-access-eu-central[0].id
  role_name              = "MemberInfrastructureBedrockEuCentral"
}

# lots of SCA ignores and skips on this one as it is the main role allowing members to build most things in the platform
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "member-access-eu-central" {
  statement {
    #checkov:skip=CKV_AWS_108
    #checkov:skip=CKV_AWS_111
    #checkov:skip=CKV_AWS_107
    #checkov:skip=CKV_AWS_109
    #checkov:skip=CKV_AWS_110
    #checkov:skip=CKV2_AWS_40
    effect = "Allow"
    actions = [
      "bedrock:*"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }
  statement {
    effect = "Deny"
    actions = [
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
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "member-access-eu-central" {
  count       = local.account_data.account-type == "member" ? 1 : 0
  name        = "MemberInfrastructureBedrockEuCentralActions"
  description = "Restricted policy for US East usage"
  policy      = data.aws_iam_policy_document.member-access-eu-central.json
}

# Create a parameter for the modernisation platform environment management secret ARN that can be used to gain
# access to the environments parameter when running a tf plan locally

resource "aws_ssm_parameter" "environment_management_arn" {
  #checkov:skip=CKV_AWS_337: Standard key is fine here
  name  = "environment_management_arn"
  type  = "SecureString"
  value = data.aws_secretsmanager_secret.environment_management.arn
  tags  = local.tags
}

# Create a parameter for the modernisation platform account id that can be used
# by providers in member accounts to assume a role in MP

resource "aws_ssm_parameter" "modernisation_platform_account_id" {
  #checkov:skip=CKV_AWS_337: Standard key is fine here
  name  = "modernisation_platform_account_id"
  type  = "SecureString"
  value = local.environment_management.modernisation_platform_account_id
  tags  = local.tags
}

# Github OIDC provider
module "github-oidc" {
  count                  = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=82f546bd5f002674138a2ccdade7d7618c6758b3" # v3.0.0
  additional_permissions = data.aws_iam_policy_document.oidc_assume_role_member[0].json
  github_repositories    = ["ministryofjustice/modernisation-platform-environments:*"]
  tags_common            = { "Name" = format("%s-oidc", terraform.workspace) }
  tags_prefix            = ""
}

data "aws_iam_policy_document" "oidc_assume_role_member" {
  count = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  statement {
    sid    = "AllowOIDCToAssumeRoles"
    effect = "Allow"
    resources = [
      format("arn:aws:iam::%s:role/member-delegation-%s-%s", local.environment_management.account_ids[format("core-vpc-%s", local.application_environment)], lower(local.business_unit), local.application_environment),
      format("arn:aws:iam::%s:role/modify-dns-records", local.environment_management.account_ids["core-network-services-production"]),
      format("arn:aws:iam::%s:role/modernisation-account-limited-read-member-access", local.environment_management.modernisation_platform_account_id),
      format("arn:aws:iam::%s:role/ModernisationPlatformSSOReadOnly", local.environment_management.aws_organizations_root_account_id),
      # the following are required as cooker have development accounts but are in the sandbox vpc
      local.application_name == "cooker" ? format("arn:aws:iam::%s:role/member-delegation-house-sandbox", local.environment_management.account_ids["core-vpc-sandbox"]) : format("arn:aws:iam::%s:role/modernisation-account-limited-read-member-access", local.environment_management.modernisation_platform_account_id)
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.root_account.id]
    }
    actions = ["sts:AssumeRole"]
  }

  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: "Cannot restrict by KMS alias so leaving open"
  statement {
    sid       = "AllowOIDCToDecryptKMS"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:Decrypt"]
  }

  statement {
    sid    = "AllowOIDCReadState"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/*",
      "arn:aws:s3:::modernisation-platform-terraform-state/"
    ]
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
  }

  statement {
    sid       = "AllowOIDCWriteState"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/environments/members/*"]
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
  }

  statement {
    sid       = "AllowOIDCDeleteLock"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/environments/members/*.tflock"]
    actions = [
      "s3:DeleteObject"
    ]
  }
}

# AWS Shield Advanced SRT (Shield Response Team) support role
module "shield_response_team_role" {
  # checkov:skip=CKV_TF_1:

  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_services = ["drt.shield.amazonaws.com"]

  create_role       = true
  role_name         = "AWSSRTSupport"
  role_requires_mfa = false

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSShieldDRTAccessPolicy"]

  number_of_custom_role_policy_arns = 1
}

# Manages the account alias for the AWS Account.
resource "aws_iam_account_alias" "alias" {
  count         = (local.account_data.account-type != "member-unrestricted") && !(contains(local.skip_alias, terraform.workspace)) ? 1 : 0
  account_alias = terraform.workspace
}

# Github OIDC provider for development and test environments

module "github_actions_dev_test_role" {
  count               = can(regex("development$|test$", terraform.workspace)) ? 1 : 0
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=62b8a16c73d8e4422cd81923e46948e8f4b5cf48" # v3.2.0
  github_repositories = ["ministryofjustice/modernisation-platform"]
  role_name           = "github-actions-dev-test"
  policy_arns         = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  policy_jsons        = [data.aws_iam_policy_document.oidc_assume_role_dev_test[0].json]
  tags                = { "Name" = format("%s-oidc-dev-test", terraform.workspace) }
}

data "aws_iam_policy_document" "oidc_assume_role_dev_test" {
  count = can(regex("development$|test$", terraform.workspace)) ? 1 : 0
  statement {
    sid    = "AllowOIDCToAssumeRoles"
    effect = "Allow"
    resources = [
      format("arn:aws:iam::%s:role/ModernisationPlatformAccess", local.environment_management.account_ids[format("core-vpc-%s", local.application_environment)]),
      format("arn:aws:iam::%s:role/ModernisationPlatformAccess", local.environment_management.account_ids["core-network-services-production"]),
      format("arn:aws:iam::%s:role/modernisation-account-limited-read-member-access", local.environment_management.modernisation_platform_account_id)
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.root_account.id]
    }
    actions = ["sts:AssumeRole"]
  }

  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: "Cannot restrict by KMS alias so leaving open"
  statement {
    sid       = "AllowOIDCToDecryptKMS"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:Decrypt"]
  }

  statement {
    sid    = "AllowOIDCReadState"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/*",
      "arn:aws:s3:::modernisation-platform-terraform-state/"
    ]
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
  }

  statement {
    sid       = "AllowOIDCWriteState"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/environments/accounts/*"]
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
  }

  statement {
    sid       = "AllowOIDCDeleteLock"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/environments/accounts/*.tflock"]
    actions = [
      "s3:DeleteObject"
    ]
  }
}

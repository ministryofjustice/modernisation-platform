locals {
  account_name = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, regex("-[^-]*$", terraform.workspace), ""))
  account_data = jsondecode(file("../../../../environments/${local.account_name}.json"))

  wiz_base_account_name = replace(terraform.workspace, regex("-[^-]*$", terraform.workspace), "")

  wiz_resource_count_allowlist = toset([
    "apex",
    "ccms-ebs-upgrade",
    "ccms-ebs",
    "ccms-edrms",
    "ccms-oia",
    "ccms-pui-internal",
    "ccms-pui",
    "contract-work-administration",
    "laa-ccms-soa",
    "laa-cst-security-dashboard",
    "laa-enterprise-service-bus",
    "laa-mail-relay",
    "laa-oem",
    "laa-pui-secure-browser",
    "laa-stabilisation-cdc-poc",
    "maat",
    "maatdb",
    "mlra",
    "mojfin",
    "oas",
    "portal",
    "cooker",
    "sprinkler",
  ])

  wiz_role_enabled = contains(local.wiz_resource_count_allowlist, local.wiz_base_account_name)
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "wiz_resource_count" {
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  count = local.wiz_role_enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",

      "ec2:DescribeRegions",
      "ec2:DescribeInstances",

      "lightsail:GetRegions",
      "lightsail:GetInstances",

      "ecs:ListClusters",
      "ecs:ListContainerInstances",
      "ecs:ListTasks",
      "ecs:DescribeTasks",

      "eks:ListClusters",
      "eks:DescribeCluster",
      "eks:ListFargateProfiles",

      "lambda:ListFunctions",
      "lambda:ListVersionsByFunction",

      "sagemaker:ListDomains",
      "sagemaker:ListEndpoints",

      "ecr:DescribeRepositories",
      "ecr:ListImages",

      "s3:ListAllMyBuckets",
      "docdb:DescribeDBClusters",
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "redshift:DescribeClusters",
      "dynamodb:ListTables"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "wiz_resource_count" {
  count       = local.wiz_role_enabled ? 1 : 0
  name        = "WizResourceCountReadOnly"
  description = "Read-only permissions for wiz/resource-count-aws-v2.py (supports --data and --images)"
  policy      = data.aws_iam_policy_document.wiz_resource_count[0].json
}

module "wiz-resource-count-access" {
  count      = local.wiz_role_enabled ? 1 : 0
  source     = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=321b0bcb8699b952a2a66f60c6242876048480d5"
  account_id = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = [
    one(data.aws_iam_roles.member-sso-admin-access.arns)
  ]
  policy_arn = aws_iam_policy.wiz_resource_count[0].arn
  role_name  = "WizResourceCountAccess"
}

module "member-access" {
  count      = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  source     = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=321b0bcb8699b952a2a66f60c6242876048480d5" #v4.0.0
  account_id = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = compact([
    module.github-oidc[0].github_actions_role,
    try(module.github_actions_terraform_dev_test[0].role, null),
    one(data.aws_iam_roles.member-sso-admin-access.arns),
  ])
  role_name = "MemberInfrastructureAccess"
}

resource "aws_iam_role_policy_attachment" "member_infrastructure_access_role_compute" {
  count      = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  role       = "MemberInfrastructureAccess"
  policy_arn = aws_iam_policy.member-access-compute[0].arn
}

resource "aws_iam_role_policy_attachment" "member_infrastructure_access_role_data" {
  count      = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  role       = "MemberInfrastructureAccess"
  policy_arn = aws_iam_policy.member-access-data[0].arn
}

resource "aws_iam_role_policy_attachment" "member_infrastructure_access_role_network" {
  count      = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  role       = "MemberInfrastructureAccess"
  policy_arn = aws_iam_policy.member-access-network[0].arn
}

module "member-access-sprinkler" {
  count                  = (terraform.workspace == "sprinkler-development") ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=321b0bcb8699b952a2a66f60c6242876048480d5" #v4.0.0
  account_id             = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = [data.aws_iam_role.sprinkler_oidc[0].arn, data.aws_iam_role.sprinkler_environments_read_only[0].arn, data.aws_iam_role.sprinkler_environments_dev_test[0].arn, one(data.aws_iam_roles.member-sso-admin-access.arns)]
  role_name              = "MemberInfrastructureAccess"
}

resource "aws_iam_role_policy_attachment" "member_infrastructure_access_sprinkler_role_compute" {
  count      = (terraform.workspace == "sprinkler-development") ? 1 : 0
  role       = "MemberInfrastructureAccess"
  policy_arn = aws_iam_policy.member-access-compute[0].arn
}

resource "aws_iam_role_policy_attachment" "member_infrastructure_access_sprinkler_role_data" {
  count      = (terraform.workspace == "sprinkler-development") ? 1 : 0
  role       = "MemberInfrastructureAccess"
  policy_arn = aws_iam_policy.member-access-data[0].arn
}

resource "aws_iam_role_policy_attachment" "member_infrastructure_access_sprinkler_role_network" {
  count      = (terraform.workspace == "sprinkler-development") ? 1 : 0
  role       = "MemberInfrastructureAccess"
  policy_arn = aws_iam_policy.member-access-network[0].arn
}


# Policy 1: Compute, Containers, and Core Services
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "member-access-compute" {
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
      "autoscaling:*",
      "backup:*",
      "backup-storage:MountCapsule",
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
      "config:*",
      "ec2:AssociateVpcCidrBlock",
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:DisassociateVpcCidrBlock",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:*RouteTable*",
      "ec2:CreateVpcEndpoint",
      "ec2:DeleteVpcEndpoints",
      "ec2:CreateVpcEndpointServiceConfiguration",
      "ec2:DeleteVpcEndpointServiceConfigurations",
      "ec2:CreateVpcPeeringConnection",
      "ec2:DeleteVpcPeeringConnection",
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
      "ec2:*ManagedPrefixList*",
      "ec2:*EncryptionControl*",
      "ecr-public:*",
      "ecr:*",
      "ecs:*",
      "eks:*",
      "elasticloadbalancing:*",
      "events:*",
      "fis:*",
      "iam:*",
      "kms:*",
      "lambda:*",
      "logs:*",
      "workspaces:*",
      "workspaces-web:*"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }
}

# Policy 2: Data and Analytics Services
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "member-access-data" {
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
      "athena:*",
      "datasync:*",
      "dbqms:*",
      "dlm:*",
      "dms:*",
      "dynamodb:*",
      "ebs:*",
      "elasticache:*",
      "elasticfilesystem:*",
      "es:*",
      "fsx:*",
      "glacier:*",
      "glue:*",
      "kinesis:*",
      "kinesisanalytics:*Application*",
      "kinesisanalytics:*Resource",
      "lakeformation:*",
      "quicksight:*",
      "rds-db:*",
      "rds:*",
      "rds-data:*",
      "redshift:*",
      "redshift-data:*",
      "redshift-serverless:*",
      "s3:*",
      "firehose:*"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }
}

# Policy 3: Networking, Security, and Additional Services
#tfsec:ignore:aws-iam-no-policy-wildcards
#trivy:ignore:AVD-AWS-0345: Required for member account access to S3
data "aws_iam_policy_document" "member-access-network" {
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
      "aps:*",
      "aoss:*",
      "bcm-data-exports:*",
      "bedrock:*",
      "chatbot:*",
      "cur:DeleteReportDefinition",
      "cur:DescribeReportDefinitions",
      "cur:ListTagsForResource",
      "cur:PutReportDefinition",
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
      "ds:CreateTrust",
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
      "ds:VerifyTrust",
      "ds-data:*",
      "grafana:*",
      "guardduty:get*",
      "networkflowmonitor:*",
      "networkmonitor:*",
      "network-firewall:*",
      "organizations:Describe*",
      "organizations:List*",
      "oam:*",
      "ram:AssociateResourceShare",
      "ram:CreateResourceShare",
      "ram:DeleteResourceShare",
      "ram:Get*",
      "ram:List*",
      "route53:*",
      "route53resolver:*",
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
      "tag:ListRequiredTags",
      "waf:*",
      "wafv2:*",
      "resource-groups:*",
      "resource-explorer-2:*",
      "transfer:*",
      "vpce:*",
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
  # Only grant Rekognition permissions for e-supervision application
  statement {
    effect    = "Allow"
    actions   = ["rekognition:*"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values = [
        local.environment_management.account_ids["hmpps-esupervision-development"],
        local.environment_management.account_ids["hmpps-esupervision-production"]
      ]
    }
  }
  statement {
    effect = "Deny"
    actions = [
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

resource "aws_iam_policy" "member-access-compute" {
  count       = local.account_data.account-type == "member" ? 1 : 0
  name        = "MemberInfrastructureAccessActionsCompute"
  description = "Restricted admin policy for member CI/CD - Compute services"
  policy      = data.aws_iam_policy_document.member-access-compute.json
}

resource "aws_iam_policy" "member-access-data" {
  count       = local.account_data.account-type == "member" ? 1 : 0
  name        = "MemberInfrastructureAccessActionsData"
  description = "Restricted admin policy for member CI/CD - Data services"
  policy      = data.aws_iam_policy_document.member-access-data.json
}

resource "aws_iam_policy" "member-access-network" {
  count       = local.account_data.account-type == "member" ? 1 : 0
  name        = "MemberInfrastructureAccessActionsNetwork"
  description = "Restricted admin policy for member CI/CD - Network and security services"
  policy      = data.aws_iam_policy_document.member-access-network.json
}

# Legacy policy name kept for backwards compatibility - combines all three
resource "aws_iam_policy" "member-access" {
  count       = 0 # Deprecated - use split policies instead
  name        = "MemberInfrastructureAccessActions"
  description = "Deprecated - split into multiple policies"
  policy      = data.aws_iam_policy_document.member-access-compute.json
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

# IAM role attached policies
resource "aws_iam_role_policy_attachment" "testing_member_infrastructure_access_role_compute" {
  count      = terraform.workspace == "testing-test" ? 1 : 0
  role       = aws_iam_role.testing_member_infrastructure_access_role[0].id
  policy_arn = aws_iam_policy.member-access-compute[0].arn
}

resource "aws_iam_role_policy_attachment" "testing_member_infrastructure_access_role_data" {
  count      = terraform.workspace == "testing-test" ? 1 : 0
  role       = aws_iam_role.testing_member_infrastructure_access_role[0].id
  policy_arn = aws_iam_policy.member-access-data[0].arn
}

resource "aws_iam_role_policy_attachment" "testing_member_infrastructure_access_role_network" {
  count      = terraform.workspace == "testing-test" ? 1 : 0
  role       = aws_iam_role.testing_member_infrastructure_access_role[0].id
  policy_arn = aws_iam_policy.member-access-network[0].arn
}

# MemberInfrastructureAccessUSEast
module "member-access-us-east" {
  count      = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  source     = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=321b0bcb8699b952a2a66f60c6242876048480d5" #v4.0.0
  account_id = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = compact([
    module.github-oidc[0].github_actions_role,
    try(module.github_actions_terraform_dev_test[0].role, null),
    one(data.aws_iam_roles.member-sso-admin-access.arns),
  ])
  policy_arn = aws_iam_policy.member-access-us-east[0].id
  role_name  = "MemberInfrastructureAccessUSEast"
}

module "member-access-us-east-sprinkler" {
  count                  = (terraform.workspace == "sprinkler-development") ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=321b0bcb8699b952a2a66f60c6242876048480d5" #v4.0.0
  account_id             = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = [data.aws_iam_role.sprinkler_oidc[0].arn, data.aws_iam_role.sprinkler_environments_read_only[0].arn, data.aws_iam_role.sprinkler_environments_dev_test[0].arn, one(data.aws_iam_roles.member-sso-admin-access.arns)]
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
    actions = [
      "acm:*",
      "iam:ListRoles",
      "lambda:*",
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

  statement {
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["lambda.amazonaws.com"]
    }
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
  source               = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
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
      "elasticloadbalancing:ModifyListener",
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
      "quicksight:*",
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
      "ssm:TerminateSession",
      "vpc:DescribeSubnets"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }

  statement {
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = ["ssm.amazonaws.com", "ecs.amazonaws.com", "ecs-tasks.amazonaws.com", "backup.amazonaws.com", "datasync.amazonaws.com"]
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
      "arn:aws:kms:eu-west-2:${local.environment_management.account_ids["electronic-monitoring-data-preproduction"]}:key/*",
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
  count      = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  source     = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=321b0bcb8699b952a2a66f60c6242876048480d5" #v4.0.0
  account_id = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = compact([
    module.github-oidc[0].github_actions_role,
    try(module.github_actions_terraform_dev_test[0].role, null),
    one(data.aws_iam_roles.member-sso-admin-access.arns),
  ])
  policy_arn = aws_iam_policy.member-access-eu-central[0].id
  role_name  = "MemberInfrastructureBedrockEuCentral"
}

module "member-access-eu-central-sprinkler" {
  count                  = (terraform.workspace == "sprinkler-development") ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=321b0bcb8699b952a2a66f60c6242876048480d5" #v4.0.0
  account_id             = data.aws_ssm_parameter.modernisation_platform_account_id.value
  additional_trust_roles = [data.aws_iam_role.sprinkler_oidc[0].arn, data.aws_iam_role.sprinkler_environments_read_only[0].arn, data.aws_iam_role.sprinkler_environments_dev_test[0].arn, one(data.aws_iam_roles.member-sso-admin-access.arns)]
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
  source                 = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=5dc9bc211d10c58de4247fa751c318a3985fc87b" # v4.0.0
  additional_permissions = data.aws_iam_policy_document.oidc_assume_role_member[0].json
  github_repositories    = ["ministryofjustice/modernisation-platform-environments:*"]
  tags_common            = { "Name" = format("%s-oidc", terraform.workspace) }
  tags_prefix            = ""
}

#trivy:ignore:AVD-AWS-0345: Required for reading/writing Terraform state from S3
data "aws_iam_policy_document" "oidc_assume_role_member" {
  count = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  statement {
    sid    = "AllowOIDCToAssumeRoles"
    effect = "Allow"
    resources = compact([
      # skip for cloud-platform as it uses a different account naming convention and does not need a member-delegation role
      local.application_name != "cloud-platform" ? format("arn:aws:iam::%s:role/member-delegation-%s-%s", local.environment_management.account_ids[format("core-vpc-%s", local.application_environment)], lower(local.business_unit), local.application_environment) : "",
      format("arn:aws:iam::%s:role/modify-dns-records", local.environment_management.account_ids["core-network-services-production"]),
      format("arn:aws:iam::%s:role/modernisation-account-limited-read-member-access", local.environment_management.modernisation_platform_account_id),
      format("arn:aws:iam::%s:role/ModernisationPlatformSSOReadOnly", local.environment_management.aws_organizations_root_account_id),
      # the following are required as cooker have development accounts but are in the sandbox vpc
      local.application_name == "cooker" ? format("arn:aws:iam::%s:role/member-delegation-house-sandbox", local.environment_management.account_ids["core-vpc-sandbox"]) : format("arn:aws:iam::%s:role/modernisation-account-limited-read-member-access", local.environment_management.modernisation_platform_account_id)
    ])
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
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
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

# GitHub OIDC Role for Security Hub Insight Creation and Summary Access
module "securityhub_insights_oidc_role" {
  count               = startswith(terraform.workspace, "core") && terraform.workspace != "core-shared-services-production" ? 0 : 1
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = ["ministryofjustice/modernisation-platform"]
  role_name           = "github-actions-securityhub-insights"
  policy_jsons        = [data.aws_iam_policy_document.securityhub_insights_oidc_policy.json]
  subject_claim       = "ref:refs/heads/main"
  tags                = { "Name" = format("%s-oidc-securityhub-insights", terraform.workspace) }
}

module "securityhub_insights_oidc_role_core" {
  count                  = startswith(terraform.workspace, "core") && terraform.workspace != "core-shared-services-production" ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=5dc9bc211d10c58de4247fa751c318a3985fc87b" # v4.0.0
  github_repositories    = ["ministryofjustice/modernisation-platform:ref:refs/heads/main"]
  role_name              = "github-actions-securityhub-insights"
  additional_permissions = data.aws_iam_policy_document.securityhub_insights_oidc_policy.json
  tags_common            = { "Name" = format("%s-oidc-securityhub-insights", terraform.workspace) }
  tags_prefix            = ""
}

data "aws_iam_policy_document" "securityhub_insights_oidc_policy" {
  # checkov:skip=CKV_AWS_111 "Required wildcard resource due to AWS Security Hub API limitations"
  # checkov:skip=CKV_AWS_356 "Wildcard resource necessary because specific ARNs not supported for these actions"
  statement {
    sid    = "AllowSecurityHubInsightActions"
    effect = "Allow"
    actions = [
      "securityhub:CreateInsight",
      "securityhub:UpdateInsight",
      "securityhub:GetInsights",
      "securityhub:GetInsightResults"
    ]
    resources = ["*"]
  }
}

module "iam_hygiene_oidc_role" {
  count = (
    local.account_data.account-type == "member-unrestricted"
    || local.account_data.account-type == "member"
  ) ? 1 : 0

  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = ["ministryofjustice/modernisation-platform"]

  role_name = "github-actions-iam-hygiene"
  policy_jsons = [
    data.aws_iam_policy_document.iam_hygiene_policy.json
  ]

  tags = {
    Name = format("%s-oidc-iam-hygiene", terraform.workspace)
  }
}

data "aws_iam_policy_document" "iam_hygiene_policy" {
  # checkov:skip=CKV_AWS_356: iam:ListUsers is not resource-scopable; wildcard required
  statement {
    sid       = "AllowListUsersForDiscovery"
    effect    = "Allow"
    actions   = ["iam:ListUsers"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowReadForDiscovery"
    effect = "Allow"
    actions = [
      "iam:ListUserTags",
      "iam:ListAccessKeys",
      "iam:GetAccessKeyLastUsed",
      "iam:ListAttachedUserPolicies",
      "iam:ListUserPolicies",
      "iam:ListGroupsForUser"
    ]
    resources = ["arn:aws:iam::*:user/*"]
  }

  statement {
    sid    = "AllowKeyLifecycle"
    effect = "Allow"
    actions = [
      "iam:UpdateAccessKey",
      "iam:DeleteAccessKey"
    ]
    resources = ["arn:aws:iam::*:user/*"]
  }

  statement {
    sid       = "AllowDisableConsoleLogin"
    effect    = "Allow"
    actions   = ["iam:DeleteLoginProfile"]
    resources = ["arn:aws:iam::*:user/*"]
  }

  # checkov:skip=CKV_AWS_109: IAM hygiene cleanup in non-admin member accounts; no tagging available; risk accepted
  # checkov:skip=CKV_AWS_356: Wildcard required for dynamic IAM user/group cleanup; limited member-account scope
  statement {
    sid    = "AllowUserDeletionCleanup"
    effect = "Allow"
    actions = [
      "iam:DetachUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:RemoveUserFromGroup",
      "iam:DeleteUser"
    ]
    resources = ["*"]
  }
}

# Role github-actions-terraform-dev-test & policy to support OIDC access from Modernisation-Platform-Environments for:
#
# - Development & Test member accounts with terraform plan & apply actions from non-main branches
# - Pre/Production member accounts with terraform plan from non-main branches
#
# Uses the same deployment conditions as the OIDC provider deployment - module.github-oidc

module "github_actions_terraform_dev_test" {
  count               = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = ["ministryofjustice/modernisation-platform-environments"]
  role_name           = "github-actions-terraform-dev-test"
  policy_jsons        = [data.aws_iam_policy_document.github_actions_terraform_dev_test[0].json]
  tags                = { "Name" = "github-actions-terraform-dev-test" }
}

#trivy:ignore:AVD-AWS-0345: Required for OIDC role to access Terraform state in S3
data "aws_iam_policy_document" "github_actions_terraform_dev_test" {
  count = (local.account_data.account-type == "member" && terraform.workspace != "testing-test" && terraform.workspace != "sprinkler-development") ? 1 : 0
  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: "Cannot restrict by KMS alias so leaving open"
  statement {
    sid    = "AllowOIDCToAssumeRoles"
    effect = "Allow"
    resources = compact([
      # skip for cloud-platform as it uses a different account naming convention and does not need a member-delegation role
      local.application_name != "cloud-platform" ? format("arn:aws:iam::%s:role/member-delegation-%s-%s", local.environment_management.account_ids[format("core-vpc-%s", local.application_environment)], lower(local.business_unit), local.application_environment) : "",
      format("arn:aws:iam::%s:role/modify-dns-records", local.environment_management.account_ids["core-network-services-production"]),
      format("arn:aws:iam::%s:role/modernisation-account-limited-read-member-access", local.environment_management.modernisation_platform_account_id),
      format("arn:aws:iam::%s:role/ModernisationPlatformSSOReadOnly", local.environment_management.aws_organizations_root_account_id),
      # the following are required as cooker have development accounts but are in the sandbox vpc
      local.application_name == "cooker" ? format("arn:aws:iam::%s:role/member-delegation-house-sandbox", local.environment_management.account_ids["core-vpc-sandbox"]) : format("arn:aws:iam::%s:role/modernisation-account-limited-read-member-access", local.environment_management.modernisation_platform_account_id)
    ])
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
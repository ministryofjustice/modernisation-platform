# IAM policies used for SSO and collaborator roles

# common policy statements
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "common_statements" {
  statement {
    sid    = "denyPermissions"
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
    sid    = "denyOnCicdMemberUser"
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
    sid = "assumeRolesInSharedAccounts"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::*:role/ModernisationPlatformSSOReadOnly",
      "arn:aws:iam::*:role/read-log-records",
      "arn:aws:iam::*:role/member-delegation-read-only",
      "arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:role/member-shared-services",
      "arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:role/ad-fixngo-ec2-access",
      "arn:aws:iam::${local.modernisation_platform_account.id}:role/modernisation-account-limited-read-member-access",
      "arn:aws:iam::${local.modernisation_platform_account.id}:role/modernisation-account-terraform-state-member-access"
    ]
  }
}
# Common policy for allow
resource "aws_iam_policy" "common_policy_permissions" {
  provider = aws.workspace
  name     = "common_policy_permissions"
  path     = "/"
  policy   = data.aws_iam_policy_document.common_policy_document.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "common_policy_document" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  source_policy_documents = [data.aws_iam_policy_document.common_statements.json]
  statement {
    sid    = "commonAllow"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecret*",
      "secretsmanager:GetSecretValue",
      "ec2:DescribeVolumes",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "kms:Decrypt*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",





    ]
  }
}


# bedrock console policy -- to be retired when terraform support is introduced
# source: https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_id-based-policy-examples.html#security_iam_id-based-policy-examples-console
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "bedrock_console" {
  #checkov:skip=CKV_AWS_111: This is a service policy
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  statement {
    sid    = "BedrockConsole"
    effect = "Allow"

    actions = [
      "bedrock:ListFoundationModels",
      "bedrock:GetFoundationModel",
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:CreateModelCustomizationJob",
      "bedrock:GetModelCustomizationJob",
      "bedrock:GetFoundationModelAvailability",
      "bedrock:ListModelCustomizationJobs",
      "bedrock:StopModelCustomizationJob",
      "bedrock:GetCustomModel",
      "bedrock:ListCustomModels",
      "bedrock:DeleteCustomModel",
      "bedrock:CreateProvisionedModelThroughput",
      "bedrock:UpdateProvisionedModelThroughput",
      "bedrock:GetProvisionedModelThroughput",
      "bedrock:DeleteProvisionedModelThroughput",
      "bedrock:ListProvisionedModelThroughputs",
      "bedrock:ListTagsForResource",
      "bedrock:UntagResource",
      "bedrock:TagResource",
      "bedrock:CreateAgent",
      "bedrock:UpdateAgent",
      "bedrock:GetAgent",
      "bedrock:ListAgents",
      "bedrock:CreateActionGroup",
      "bedrock:UpdateActionGroup",
      "bedrock:GetActionGroup",
      "bedrock:ListActionGroups",
      "bedrock:CreateAgentDraftSnapshot",
      "bedrock:GetAgentVersion",
      "bedrock:ListAgentVersions",
      "bedrock:CreateAgentAlias",
      "bedrock:UpdateAgentAlias",
      "bedrock:GetAgentAlias",
      "bedrock:ListAgentAliases",
      "bedrock:InvokeAgent",
      "bedrock:PutFoundationModelEntitlement",
      "bedrock:GetModelInvocationLoggingConfiguration",
      "bedrock:PutModelInvocationLoggingConfiguration",
      "bedrock:CreateFoundationModelAgreement",
      "bedrock:DeleteFoundationModelAgreement",
      "bedrock:ListFoundationModelAgreementOffers",
      "bedrock:GetUseCaseForModelAccess",
      "bedrock:PutUseCaseForModelAccess"
    ]

    resources = ["*"]
  }
}

# developer policy - member SSO and collaborators
resource "aws_iam_policy" "developer" {
  provider = aws.workspace
  name     = "developer_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.developer_additional.json
}


#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "developer_additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  source_policy_documents = [data.aws_iam_policy_document.common_statements.json]
  statement {
    sid    = "developerAllow"
    effect = "Allow"
    actions = [
      "acm:ImportCertificate",
      "acm:AddTagsToCertificate",
      "acm:RemoveTagsFromCertificate",
      "application-autoscaling:ListTagsForResource",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:SetDesiredCapacity",
      "athena:Get*",
      "athena:List*",
      "athena:St*",
      "aws-marketplace:ViewSubscriptions",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:PutDashboard",
      "cloudwatch:List*",
      "cloudwatch:DeleteDashboards",
      "codebuild:ImportSourceCredentials",
      "codebuild:PersistOAuthToken",
      "cur:DescribeReportDefinitions",
      "ds:*Tags*",
      "ds:*Snapshot*",
      "ds:ResetUserPassword",
      "ec2:St*",
      "ec2:RebootInstances",
      "ec2:Modify*",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateVolume",
      "ec2:CopySnapshot",
      "ec2:CreateSnapshot*",
      "ec2:CreateTags",
      "ec2:ModifyInstanceAttribute",
      "ec2-instance-connect:SendSerialConsoleSSHPublicKey",
      "ecr:BatchDeleteImage",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:ListTagsForResource",
      "ecs:ListServices",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "ecs:ExecuteCommand",
      "events:DisableRule",
      "events:EnableRule",
      "identitystore:DescribeUser",
      "kms:CreateGrant",
      "lambda:InvokeFunction",
      "lambda:UpdateFunctionCode",
      "rds:AddTagsToResource",
      "rds:CopyDB*",
      "rds:Create*",
      "rds:ModifyDBSnapshotAttribute",
      "rds:RestoreDBInstanceToPointInTime",
      "rds:RebootDB*",
      "rhelkb:GetRhelURL",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:RestoreObject",
      "s3:*StorageLens*",
      "secretsmanager:Get*",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:RestoreSecret",
      "secretsmanager:RotateSecret",
      "servicequotas:*",
      "ses:DeleteSuppressedDestination",
      "ses:PutAccountDetails",
      "ssm:*",
      "ssm-guiconnect:*",
      "sso:ListDirectoryAssociations",
      "support:*",
      "wellarchitected:Get*",
      "wellarchitected:List*",
      "wellarchitected:ExportLens",
      "states:Describe*",
      "states:List*",
      "states:Stop*",
      "states:Start*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "snsAllow"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = ["arn:aws:sns:*:*:Automation*"]
  }

  statement {
    sid    = "lambdaAllow"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = ["arn:aws:lambda:*:*:function:Automation*"]
  }

  statement {
    sid    = "iamOnCicdMemberAllow"
    effect = "Allow"
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

  statement {
    sid    = "iamForECSAllow"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs.amazonaws.com"]
    }
  }

  statement {
    sid    = "coreSharedServicesCreateGrantAllow"
    effect = "Allow"
    actions = [
      "kms:CreateGrant"
    ]
    resources = ["arn:aws:kms:*:${local.environment_management.account_ids["core-shared-services-production"]}:key/*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "data_engineering_additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  source_policy_documents = [data.aws_iam_policy_document.developer_additional.json] # this is a developer++ policy with additional permissions required for data engineering
  statement {
    sid    = "DataEngineeringAllow"
    effect = "Allow"
    actions = [
      "airflow:ListEnvironments",
      "airflow:GetEnvironment",
      "airflow:ListTagsForResource",
      "athena:DeleteNamedQuery",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "ce:CreateReport",
      "dms:StartReplicationTask",
      "dms:StopReplicationTask",
      "dms:ModifyReplicationTask",
      "glue:Batch*Partition",
      "glue:BatchDeleteTable",
      "glue:CreateDatabase",
      "glue:CreatePartition",
      "glue:CreateTable",
      "glue:DeleteDatabase",
      "glue:DeletePartition",
      "glue:DeleteTable",
      "glue:*JobRun",
      "glue:UpdateDatabase",
      "glue:UpdatePartition",
      "glue:UpdateTable",
      "glue:*DefinedFunction",
      "glue:*Job",
      "glue:Get*",
      "glue:List*",
      "glue:BatchGetJobs",
      "glue:*Trigger",
      "states:Describe*",
      "states:List*",
      "states:Stop*",
      "states:Start*",
      "states:RedriveExecution",
      "s3:PutBucketNotificationConfiguration",
    ]
    resources = ["*"]
  }
  statement {
    sid       = "AirflowUIAccess"
    effect    = "Allow"
    actions   = ["airflow:CreateWebLoginToken"]
    resources = ["arn:aws:airflow:eu-west-1:${local.environment_management.account_ids["analytical-platform-data-production"]}:role/*/User"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.environment_management.account_ids["analytical-platform-data-production"]}:role/data-first-data-science"]
  }
}

# data engineerin policy (developer + glue + some athena)
resource "aws_iam_policy" "data_engineering" {
  provider = aws.workspace
  name     = "data_engineering_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.data_engineering_additional.json
}

# sandbox policy - member SSO and collaborators, development accounts only
resource "aws_iam_policy" "sandbox" {
  provider = aws.workspace
  name     = "sandbox_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.sandbox_additional.json
}
##checks being skipped until policy has been amended##
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "sandbox_additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_107
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV2_AWS_40
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  source_policy_documents = [data.aws_iam_policy_document.common_statements.json, data.aws_iam_policy_document.bedrock_console.json]
  # added as a source document to ease retirement
  statement {
    sid    = "sandboxAllow"
    effect = "Allow"
    actions = [
      "acm-pca:*",
      "acm:*",
      "airflow:*",
      "apigateway:*",
      "application-autoscaling:*",
      "appstream:*",
      "athena:*",
      "autoscaling:*",
      "cloudformation:*",
      "cloudfront:*",
      "cloudwatch:*",
      "codebuild:ImportSourceCredentials",
      "codebuild:PersistOAuthToken",
      "cognito-identity:*",
      "cognito-idp:*",
      "cur:DescribeReportDefinitions",
      "datasync:*",
      "dbqms:*",
      "dlm:*",
      "dynamodb:*",
      "dms:*",
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
      "eks:AccessKubernetesApi",
      "eks:Describe*",
      "eks:List*",
      "elasticache:*",
      "elasticfilesystem:*",
      "elasticloadbalancing:*",
      "events:*",
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
      "scheduler:CreateSchedule",
      "secretsmanager:*",
      "ses:*",
      "sns:*",
      "sqs:*",
      "ssm:*",
      "wafv2:*",
      "redshift:*",
      "redshift-data:*",
      "redshift-serverless:*",
      "sqlworkbench:*",
      "mgn:*",
      "drs:*",
      "mgh:*",
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
      "support:*",
      "ssm-guiconnect:*",
      "aws-marketplace:ViewSubscriptions",
      "rhelkb:GetRhelURL",
      "identitystore:DescribeUser",
      "sso:ListDirectoryAssociations",
      "wellarchitected:*",
      "backup:*",
      "states:*"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }
}

# migration policy - member SSO and collaborators
# developer role plus additional migration permissions
resource "aws_iam_policy" "migration" {
  provider = aws.workspace
  name     = "migration_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.migration_additional.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "migration_additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_107
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  source_policy_documents   = [data.aws_iam_policy_document.developer_additional.json]
  override_policy_documents = [data.aws_iam_policy_document.common_statements.json]
  statement {
    sid    = "migrationAllow"
    effect = "Allow"
    actions = [
      "datasync:*",
      "discovery:*",
      "dms:*",
      "drs:*",
      "mgh:*",
      "mgn:*",
      "sts:DecodeAuthorizationMessage",
      "migrationhub-strategy:*"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }

  statement {
    sid    = "iamOnUsersAllow"
    effect = "Allow"
    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:GetUser",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "migrationPassRole"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::*:role/service-role/AWSApplicationMigrationConversionServerRole"]
  }
}


# instance management - member SSO and collaborators
resource "aws_iam_policy" "instance-management" {
  provider = aws.workspace
  name     = "instance_management_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.instance-management-document.json
}


#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "instance-management-document" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  source_policy_documents = [data.aws_iam_policy_document.common_statements.json]
  statement {
    sid    = "databaseAllow"
    effect = "Allow"
    actions = [
      "aws-marketplace:ViewSubscriptions",
      "ds:*Tags*",
      "ds:*Snapshot*",
      "ds:ResetUserPassword",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:RebootInstances",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CopySnapshot",
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:CreateTags",
      "ecs:ListServices",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "identitystore:DescribeUser",
      "rds:CopyDBSnapshot",
      "rds:CopyDBClusterSnapshot",
      "rds:CreateDBSnapshot",
      "rds:CreateDBClusterSnapshot",
      "rds:RebootDB*",
      "rhelkb:GetRhelURL",
      "s3:List*",
      "s3:Get*",
      "s3:PutObject",
      "ssm:*",
      "ssm-guiconnect:*",
      "sso:ListDirectoryAssociations",
      "support:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "snsAllow"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = ["arn:aws:sns:*:*:Automation*"]
  }

  statement {
    sid    = "lambdaAllow"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = ["arn:aws:lambda:*:*:function:Automation*"]
  }

  statement {
    sid    = "coreSharedServicesCreateGrantAllow"
    effect = "Allow"
    actions = [
      "kms:CreateGrant"
    ]
    resources = ["arn:aws:kms:*:${local.environment_management.account_ids["core-shared-services-production"]}:key/*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

# reporting-operations policy
resource "aws_iam_policy" "reporting-operations" {
  provider = aws.workspace
  name     = "reporting_operations_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.reporting-operations.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "reporting-operations" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_107
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356:
  override_policy_documents = [data.aws_iam_policy_document.common_statements.json]
  statement {
    sid    = "reportingOperationsAllow"
    effect = "Allow"
    actions = [
      "dms:DescribeReplicationInstances",
      "dms:DescribeReplicationTasks",
      "dms:StartReplicationTaskAssessmentRun",
      "dms:StartReplicationTask",
      "dms:StopReplicationTask",
      "dms:TestConnection",
      "dms:ReloadTables",
      "sqlworkbench:CreateFolder",
      "sqlworkbench:PutTab",
      "sqlworkbench:BatchDeleteFolder",
      "sqlworkbench:DeleteTab",
      "sqlworkbench:GenerateSession",
      "sqlworkbench:GetAccountInfo",
      "sqlworkbench:GetAccountSettings",
      "sqlworkbench:GetUserInfo",
      "sqlworkbench:GetUserWorkspaceSettings",
      "sqlworkbench:PutUserWorkspaceSettings",
      "sqlworkbench:ListConnections",
      "sqlworkbench:ListFiles",
      "sqlworkbench:ListTabs",
      "sqlworkbench:UpdateFolder",
      "sqlworkbench:ListRedshiftClusters",
      "sqlworkbench:DriverExecute",
      "sqlworkbench:ListTaggedResources",
      "sqlworkbench:ListQueryExecutionHistory",
      "sqlworkbench:GetQueryExecutionHistory",
      "sqlworkbench:ListNotebooks",
      "sqlworkbench:GetSchemaInference",
      "sqlworkbench:CreateAccount",
      "sqlworkbench:TagResource",
      "sqlworkbench:CreateConnection",
      "sqlworkbench:GetConnection",
      "sqlworkbench:UpdateConnection",
      "sqlworkbench:GetAutocompletionMetadata",
      "sqlworkbench:GetAutocompletionResource",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:List*",
      "athena:GetDatabase",
      "athena:GetDataCatalog",
      "athena:GetTableMetadata",
      "athena:ListDatabases",
      "athena:ListDataCatalogs",
      "athena:ListTableMetadata",
      "athena:ListWorkGroups",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetWorkGroup",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "s3:List*",
      "s3:Get*",
      "s3:PutObject",
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "ec2:DescribeInstances",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "glue:GetTables",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetDatabase",
      "glue:GetPartition",
      "glue:StartJobRun",
      "glue:BatchStopJobRun",
      "glue:ResetJobBookmark",
      "glue:UpdateJob",
      "glue:UseGlueStudio",
      "glue:GetJobs",
      "glue:GetJobRun",
      "glue:GetJobRuns",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "iam:PassRole",
      "redshift:*",
      "redshift-data:*",
      "redshift-serverless:*",
      "kinesis:Get*",
      "kinesis:DescribeStreamSummary",
      "kinesis:ListStreams",
      "kinesis:PutRecord",
      "kinesis:CreateStream",
      "cloudwatch:GetDashboard",
      "cloudwatch:ListDashboards",
      "states:StartExecution",
      "states:StopExecution",
      "states:RedriveExecution"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "powerbi_user_additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_107
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  override_policy_documents = [data.aws_iam_policy_document.common_statements.json]
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::alpha-everyone/*",
      "arn:aws:s3:::alpha-postcodes/database/postcodes/*",
      "arn:aws:s3:::alpha-postcodes/database/names/*",
      "arn:aws:s3:::mojap-derived-tables/prod/models/*",
      "arn:aws:s3:::mojap-derived-tables/dev/models/*",
      "arn:aws:s3:::mojap-derived-tables/seeds/*"
    ]
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion"
    ]
    sid = "S3ReadOnly"
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::alpha-everyone",
      "arn:aws:s3:::alpha-postcodes",
      "arn:aws:s3:::dbt-query-dump",
      "arn:aws:s3:::mojap-derived-tables",
      "arn:aws:s3:::alpha-athena-query-dump",
      "arn:aws:s3:::mojap-athena-query-dump",
      "arn:aws:s3:::alpha-everyone/*",
      "arn:aws:s3:::alpha-postcodes/database/postcodes/*",
      "arn:aws:s3:::alpha-postcodes/database/names/*",
      "arn:aws:s3:::mojap-derived-tables/prod/models/*",
      "arn:aws:s3:::mojap-derived-tables/dev/models/*",
      "arn:aws:s3:::mojap-derived-tables/seeds/*"
    ]
    sid = "List"
  }

  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::aws-athena-query-results-*"]
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    sid = "ReadWriteQueryResults"
  }

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::alpha-athena-query-dump/$${aws:userid}/*",
      "arn:aws:s3:::mojap-athena-query-dump/$${aws:userid}/*"
    ]
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    sid = "ReadWriteQueryDump"
  }

  statement {
    sid       = "AllowReadAthenaGlue"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "athena:BatchGetNamedQuery",
      "athena:BatchGetQueryExecution",
      "athena:GetNamedQuery",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryResultsStream",
      "athena:GetWorkGroup",
      "athena:ListNamedQueries",
      "athena:ListWorkGroups",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:CancelQueryExecution",
      "athena:GetCatalogs",
      "athena:GetExecutionEngine",
      "athena:GetExecutionEngines",
      "athena:GetNamespace",
      "athena:GetNamespaces",
      "athena:GetTable",
      "athena:GetTables",
      "athena:RunQuery",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:GetCatalogImportStatus",
      "glue:GetUserDefinedFunction",
      "glue:GetUserDefinedFunctions"
    ]
  }

  statement {
    sid       = "AllowGetPutObject"
    effect    = "Allow"
    resources = ["arn:aws:s3:::aws-athena-query-results-593291632749-eu-west-1/*"]
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ssm:*"
    ]
  }

}

resource "aws_iam_policy" "powerbi_user" {
  provider = aws.workspace
  name     = "powerbi_user"
  path     = "/"
  policy   = data.aws_iam_policy_document.powerbi_user_additional.json
}

resource "aws_iam_policy" "fleet-manager-policy" {
  provider = aws.workspace
  name     = "fleet_manager_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.fleet-manager-document.json
}


data "aws_iam_policy_document" "fleet-manager-document" {
  #checkov:skip=CKV_AWS_111 Needs to access multiple resources and the policy is attached to a role that is scoped to a specific account
  #checkov:skip=CKV_AWS_356 Needs to access multiple resources and the policy is attached to a role that is scoped to a specific account
  override_policy_documents = [data.aws_iam_policy_document.common_statements.json]
  statement {
    sid    = "FleetManagerAllow"
    effect = "Allow"
    actions = [
      "ssm:DescribeSessions",
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ssm-guiconnect:StartConnection",
      "ssm-guiconnect:GetConnection",
      "ssm:StartSession"
    ]
    resources = ["*"]
  }
}

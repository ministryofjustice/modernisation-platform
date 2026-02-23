# IAM policies used for SSO and collaborator roles

# common policy and statements
resource "aws_iam_policy" "common_policy" {
  provider = aws.workspace
  name     = "common_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.common_statements.json
}

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
      "arn:aws:iam::${data.aws_ssm_parameter.modernisation_platform_account_id.value}:role/modernisation-account-limited-read-member-access"
    ]
  }
}

# bedrock console policy -- to be retired when terraform support is introduced
# bedrock policy - member SSO and collaborators
resource "aws_iam_policy" "bedrock_policy" {
  provider = aws.workspace
  name     = "bedrock_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.bedrock_console.json
}

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
  statement {
    sid    = "developerAllow"
    effect = "Allow"
    actions = [
      "acm:ImportCertificate",
      "acm:AddTagsToCertificate",
      "acm:RemoveTagsFromCertificate",
      "application-autoscaling:ListTagsForResource",
      "autoscaling:StartInstanceRefresh",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:SetDesiredCapacity",
      "athena:Get*",
      "athena:List*",
      "athena:St*",
      "aws-marketplace:ViewSubscriptions",
      "backup:StartBackupJob",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:PutDashboard",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:List*",
      "cloudwatch:DeleteDashboards",
      "codebuild:ImportSourceCredentials",
      "codebuild:PersistOAuthToken",
      "compute-optimizer:*",
      "cur:DescribeReportDefinitions",
      "datasync:DescribeTask",
      "datasync:ListTasks",
      "datasync:StartTaskExecution",
      "datasync:TagResource",
      "ds:AccessDSData",
      "ds:*Tags*",
      "ds:*Snapshot*",
      "ds:ResetUserPassword",
      "ds-data:Describe*",
      "ds-data:List*",
      "ds-data:Search*",
      "ec2:AttachVolume",
      "ec2:St*",
      "ec2:RebootInstances",
      "ec2:Modify*",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateImageUsageReport",
      "ec2:CreateVolume",
      "ec2:CopySnapshot",
      "ec2:CreateSnapshot*",
      "ec2:CreateTags",
      "ec2:DeleteSnapshot",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeSnapshots",
      "ec2:DescribeVolumes",
      "ec2:ImportImage",
      "ec2:ImportSnapshot",
      "ec2:RegisterImage",
      "ec2:*SerialConsole*",
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
      "eks:AccessKubernetesApi",
      "eks:Describe*",
      "eks:List*",
      "elasticloadbalancing:modifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "events:DisableRule",
      "events:EnableRule",
      "fis:*",
      "glue:GetConnection",
      "glue:GetConnections",
      "guardduty:*",
      "iam:CreateServiceLinkedRole",
      "identitystore:DescribeUser",
      "kinesisanalytics:List*",
      "kinesisanalytics:Describe*",
      "kinesisanalytics:DiscoverInputSchema",
      "kms:Decrypt*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "lambda:InvokeFunction",
      "lambda:UpdateFunctionCode",
      "oam:ListTagsForResource",
      "rds:AddTagsToResource",
      "rds:CopyDB*",
      "rds:Create*",
      "rds:ModifyDBSnapshotAttribute",
      "rds:RestoreDBInstanceToPointInTime",
      "rds:RebootDB*",
      "rhelkb:GetRhelURL",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl",
      "s3:RestoreObject",
      "s3:*StorageLens*",
      "sagemaker:Describe*",
      "sagemaker:List*",
      "sagemaker:Query*",
      "secretsmanager:Get*",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:RestoreSecret",
      "secretsmanager:RotateSecret",
      "securityhub:BatchUpdateFindings",
      "servicequotas:*",
      "ses:DeleteSuppressedDestination",
      "ses:PutAccountDetails",
      "ssm:*",
      "ssm-guiconnect:*",
      "sso:ListDirectoryAssociations",
      "support:*",
      "support-console:*",
      "states:Describe*",
      "states:List*",
      "states:Stop*",
      "states:Start*",
      "wellarchitected:Get*",
      "wellarchitected:List*",
      "wellarchitected:ExportLens",
      "workspaces-web:ListSessions"
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
    sid       = "iamForECSAllow"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs.amazonaws.com"]
    }
  }

  statement {
    sid    = "cloudWatchCrossAccountAllow"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["arn:aws:iam::*:role/aws-service-role/cloudwatch-crossaccount.amazonaws.com/AWSServiceRoleForCloudWatchCrossAccount"]
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

  # Additional statement that allows for the creation of on-demand AWS Backups.
  statement {
    sid       = "AllowPassRoleForBackup"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/AWSBackup"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["backup.amazonaws.com"]
    }
  }

}

# data engineering policy (developer + glue + some athena)
resource "aws_iam_policy" "data_engineering" {
  provider = aws.workspace
  name     = "data_engineering_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.data_engineering_additional.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "data_engineering_additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
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
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "glue:Batch*Partition",
      "glue:BatchDeleteTable",
      "glue:CreateDatabase",
      "glue:CreatePartition",
      "glue:StartCrawler",
      "glue:CreateSession",
      "glue:CreateTable",
      "glue:DeleteDatabase",
      "glue:DeletePartition",
      "glue:DeleteTable",
      "glue:Describe*",
      "glue:*JobRun",
      "glue:RunStatement",
      "glue:UpdateDatabase",
      "glue:UpdatePartition",
      "glue:UpdateTable",
      "glue:*DefinedFunction",
      "glue:*Job",
      "glue:Get*",
      "glue:List*",
      "glue:BatchGetJobs",
      "glue:*Trigger",
      "glue:TagResource",
      "glue:UntagResource",
      "lakeformation:GetDataLakeSettings",
      "lakeformation:PutDataLakeSettings",
      "lakeformation:GrantPermissions",
      "lakeformation:BatchGrantPermissions",
      "lakeformation:RevokePermissions",
      "lakeformation:BatchRevokePermissions",
      "lakeformation:ListLakeFormationOptIns",
      "lakeformation:CreateLakeFormationOptIn",
      "lakeformation:DeleteLakeFormationOptIn",
      "lakeformation:ListLFTagExpressions",
      "lakeformation:GetLFTagExpression",
      "lakeformation:AddLFTagsToResource",
      "lakeformation:RemoveLFTagsFromResource",
      "lakeformation:GetDataAccess",
      "lambda:PutRuntimeManagementConfig",
      "sqs:StartMessageMoveTask",
      "sqs:CancelMessageMoveTask",
      "sqs:ListMessageMoveTasks",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:SendMessage",
      "sqs:PurgeQueue",
      "states:Describe*",
      "states:List*",
      "states:Stop*",
      "states:Start*",
      "states:RedriveExecution",
      "s3:PutBucketNotificationConfiguration",
      "s3:CreateJob",
      "s3:GetBucketOwnershipControls",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:UpdateJobStatus",
      "s3tables:*"
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
    sid     = ""
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${local.environment_management.account_ids["analytical-platform-data-production"]}:role/data-first-data-science",
      "arn:aws:iam::${local.environment_management.account_ids["electronic-monitoring-data-production"]}:role/glue-notebook-role-tf",
      "arn:aws:iam::${local.environment_management.account_ids["electronic-monitoring-data-test"]}:role/AWSS3BucketReplication*",
      "arn:aws:iam::${local.environment_management.account_ids["electronic-monitoring-data-preproduction"]}:role/AWSS3BucketReplication*"
    ]
  }

  statement {
    sid       = "AllowAssumeAnalyticalPlatformDataEngineeringStateAccessRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${local.environment_management.account_ids["analytical-platform-management-production"]}:role/data-engineering-state-access"]
  }
}

# quicksight administrator policy (IAM permissions needed to manage QuickSight subscription)
# ref: https://docs.aws.amazon.com/quicksight/latest/user/iam-policy-examples.html#security_iam_conosole-administration
resource "aws_iam_policy" "quicksight_administrator" {
  provider = aws.workspace
  name     = "quicksight_administrator_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.quicksight_administrator_additional.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "quicksight_administrator_additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  statement {
    sid    = "QuickSightConsoleAdmin"
    effect = "Allow"

    actions = [
      "athena:ListDataCatalogs",
      "athena:GetDataCatalog",
      "ds:AuthorizeApplication",
      "ds:UnauthorizeApplication",
      "ds:CheckAlias",
      "ds:CreateAlias",
      "ds:DescribeDirectories",
      "ds:DescribeTrusts",
      "ds:DeleteDirectory",
      "ds:CreateIdentityPoolDirectory",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:GetPolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:DeleteRole",
      "iam:CreateRole",
      "iam:GetRole",
      "iam:ListRoles",
      "iam:CreatePolicy",
      "iam:ListEntitiesForPolicy",
      "iam:ListPolicies",
      "organizations:DescribeOrganization",
      "quicksight:*",
      "s3:ListAllMyBuckets",
      "sso:DescribeApplication",
      "sso:DescribeInstance",
      "sso:CreateApplication",
      "sso:PutApplicationAuthenticationMethod",
      "sso:PutApplicationGrant",
      "sso:DeleteApplication",
      "sso:GetProfile",
      "sso:CreateApplicationAssignment",
      "sso:DeleteApplicationAssignment",
      "sso:ListInstances",
      "sso:DescribeRegisteredRegions"
    ]

    resources = ["*"]
  }
}

# policy for the platform engineer role
resource "aws_iam_policy" "platform_engineer_admin" {
  provider = aws.workspace
  name     = "platform_engineer_admin_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.platform_engineer_additional_additional.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
#trivy:ignore:AVD-AWS-0345: Required for platform engineer access to S3 resources
data "aws_iam_policy_document" "platform_engineer_additional_additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_107
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  #checkov:skip=CKV2_AWS_40
  statement {
    sid    = "PlatformEngineerAdmin"
    effect = "Allow"
    actions = [
      "acm:*",
      "acm-pca:*",
      "airflow:*",
      "apigateway:*",
      "application-autoscaling:*",
      "appstream:*",
      "athena:*",
      "autoscaling:*",
      "aws-marketplace:ViewSubscriptions",
      "backup:*",
      "bedrock:*",
      "ce:*",
      "cloudformation:*",
      "cloudfront:*",
      "cloudtrail:*",
      "cloudwatch:*",
      "codebuild:*",
      "codedeploy:*",
      "codepipeline:*",
      "cognito-identity:*",
      "cognito-idp:*",
      "cur:DescribeReportDefinitions",
      "datasync:*",
      "dbqms:*",
      "discovery:*",
      "detective:*",
      "dlm:*",
      "dms:*",
      "drs:*",
      "ds:*",
      "ds-data:*",
      "dynamodb:*",
      "ebs:*",
      "ec2:*",
      "ec2-instance-connect:*",
      "ecr-public:*",
      "ecr:*",
      "ecs:*",
      "eks:*",
      "elasticache:*",
      "elasticfilesystem:*",
      "elasticloadbalancing:*",
      "events:*",
      "glacier:*",
      "glue:*",
      "guardduty:*",
      "iam:*",
      "identitystore:*",
      "kinesis:*",
      "kinesisanalytics:*",
      "kms:*",
      "lakeformation:*",
      "lambda:*",
      "logs:*",
      "mgh:*",
      "mgn:*",
      "migrationhub-strategy:*",
      "networkflowmonitor:*",
      "networkmonitor:*",
      "network-firewall:*",
      "oam:*",
      "organizations:DescribeOrganization",
      "quicksight:*",
      "ram:*",
      "rds-data:*",
      "rds-db:*",
      "rds:*",
      "redshift-data:*",
      "redshift-serverless:*",
      "redshift:*",
      "rhelkb:GetRhelURL",
      "route53:*",
      "s3:*",
      "sagemaker:*",
      "scheduler:*",
      "secretsmanager:*",
      "servicequotas:*",
      "ses:*",
      "sns:*",
      "sqs:*",
      "sqlworkbench:*",
      "ssm:*",
      "ssm-guiconnect:*",
      "sso:*",
      "states:*",
      "sts:*",
      "support:*",
      "support-console:*",
      "textract:*",
      "tiros:*",
      "transfer:*",
      "vpce:*",
      "wafv2:*",
      "wellarchitected:*",
      "workspaces-web:*"
    ]
    resources = ["*"]
  }

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
#trivy:ignore:AVD-AWS-0345: Required for sandbox environment S3 access
data "aws_iam_policy_document" "sandbox_additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_107
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV2_AWS_40
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
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
      "aws-marketplace:ViewSubscriptions",
      "backup:*",
      "cloudformation:*",
      "cloudfront:*",
      "cloudwatch:*",
      "codebuild:ImportSourceCredentials",
      "codebuild:PersistOAuthToken",
      "codedeploy:*",
      "cognito-identity:*",
      "cognito-idp:*",
      "cur:DescribeReportDefinitions",
      "datasync:*",
      "dbqms:*",
      "dlm:*",
      "dms:*",
      "drs:*",
      "ds-data:Describe*",
      "ds-data:List*",
      "ds-data:Search*",
      "ds:*Tags*",
      "ds:AccessDSData",
      "ds:CancelSchemaExtension",
      "ds:CheckAlias",
      "ds:CreateAlias",
      "ds:CreateComputer",
      "ds:CreateDirectory",
      "ds:CreateLogSubscription",
      "ds:CreateMicrosoftAD",
      "ds:CreateSnapshot",
      "ds:Delete*",
      "ds:Deregister*",
      "ds:Describe*",
      "ds:Disable*",
      "ds:Enable*",
      "ds:List*",
      "ds:RegisterCertificate",
      "ds:RegisterEventTopic",
      "ds:ResetUserPassword",
      "ds:RestoreFromSnapshot",
      "ds:StartSchemaExtension",
      "ds:Update*",
      "dynamodb:*",
      "ebs:*",
      "ec2-instance-connect:SendSerialConsoleSSHPublicKey",
      "ec2:*Address*",
      "ec2:*CapacityReservation*",
      "ec2:*Ebs*",
      "ec2:*Event*",
      "ec2:*Fleet*",
      "ec2:*IdFormat*",
      "ec2:*Image*",
      "ec2:*Instance*",
      "ec2:*KeyPair*",
      "ec2:*LaunchTemplate*",
      "ec2:*NetworkInterface*",
      "ec2:*PlacementGroup*",
      "ec2:*SecurityGroup*",
      "ec2:*SerialConsole*",
      "ec2:*Snapshot*",
      "ec2:*Spot*",
      "ec2:*Tags*",
      "ec2:*Volume*",
      "ec2:Describe*",
      "ec2:Get*",
      "ec2:SendDiagnosticInterrupt",
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
      "firehose:*",
      "fis:*",
      "glacier:*",
      "glue:*",
      "guardduty:*",
      "iam:*",
      "identitystore:DescribeUser",
      "kinesis:*",
      "kinesisanalytics:*",
      "kms:*",
      "lakeformation:*",
      "lambda:*",
      "logs:*",
      "mgh:*",
      "mgn:*",
      "organizations:Describe*",
      "organizations:List*",
      "quicksight:*",
      "rds-data:*",
      "rds-db:*",
      "rds:*",
      "redshift-data:*",
      "redshift-serverless:*",
      "redshift:*",
      "rhelkb:GetRhelURL",
      "route53:*",
      "s3:*",
      "sagemaker:*",
      "scheduler:*",
      "secretsmanager:*",
      "securityhub:BatchUpdateFindings",
      "ses:*",
      "sns:*",
      "sqlworkbench:*",
      "sqs:*",
      "ssm-guiconnect:*",
      "ssm-quicksetup:*",
      "ssm:*",
      "sso:ListDirectoryAssociations",
      "states:*",
      "support:*",
      "support-console:*",
      "textract:*",
      "transfer:*",
      "wafv2:*",
      "wellarchitected:*",
      "workspaces-web:*"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }
  statement {
    sid = "sandboxSSOAllow"
    actions = [
      "sso:CreateApplicationAssignment"
    ]
    effect = "Allow"
    # This allows the sandbox role to update QuickSight groups which are linked to Identity Center

    resources = [
      "arn:aws:sso::${local.environment_management.aws_organizations_root_account_id}:application/ssoins-7535d9af4f41fb26/*" #tfsec:ignore:AWS099 tfsec:ignore:AWS097
    ]
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
      "migrationhub-strategy:*",
      "ssm:*",
      "ssm-guiconnect:*",
      "sts:DecodeAuthorizationMessage"
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

# instance access - member SSO and collaborators
resource "aws_iam_policy" "instance-access" {
  provider = aws.workspace
  name     = "instance_access_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.instance-access-document.json
}

# cut down version of instance-management policy
# Use instance-access-policy tag on resources to control access:
#   tag doesn't exist = s3 put; no secret access;  ec2 ssm full access
#   "none"            = s3 put; no secret access;  no ec2 ssm access
#   "limited"         = s3 put; read-only  secret; ec2 ssm ssh/port-forwarding only
#   "full"            = s3 put; read-write secret; ec2 ssm full access; ec2 sso local admin
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "instance-access-document" {
  #checkov:skip=CKV_AWS_107
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  source_policy_documents = [data.aws_iam_policy_document.common_statements.json]
  statement {
    sid    = "InstanceAccess"
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "ec2:GetPasswordData",
      "kms:Decrypt*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "rhelkb:GetRhelURL",
      "s3:PutObject",
      "ssm-guiconnect:*",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "SecretsManagerGet"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "secretsmanager:ResourceTag/instance-access-policy"
      values   = ["limited"]
    }
  }
  statement {
    sid    = "SecretsManagerPut"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "secretsmanager:ResourceTag/instance-access-policy"
      values   = ["full"]
    }
  }
  statement {
    sid    = "SSMStartSessionPortForwarding"
    effect = "Allow"
    actions = [
      "ssm:StartSession"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ssm:*:*:managed-instance/*",
      "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSession",
    ]
    condition {
      test     = "BoolIfExists"
      variable = "ssm:SessionDocumentAccessCheck"
      values   = ["true"]
    }
    condition {
      test     = "StringEqualsIfExists"
      variable = "ssm:resourceTag/instance-access-policy"
      values   = ["limited"] # doesn't work as expected with granular tags, e.g. use ssh/portforward
    }
  }
  statement {
    sid    = "SSMStartSessionSSH"
    effect = "Allow"
    actions = [
      "ssm:StartSession"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ssm:*:*:managed-instance/*",
      "arn:aws:ssm:*:*:document/AWS-StartSSHSession",
    ]
    condition {
      test     = "BoolIfExists"
      variable = "ssm:SessionDocumentAccessCheck"
      values   = ["true"]
    }
    condition {
      test     = "StringEqualsIfExists"
      variable = "ssm:resourceTag/instance-access-policy"
      values   = ["limited"]
    }
  }
  statement {
    sid    = "SSMStartSession"
    effect = "Allow"
    actions = [
      "ssm:StartSession"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ssm:*:*:managed-instance/*",
    ]
    condition {
      test     = "StringEqualsIfExists"
      variable = "ssm:resourceTag/instance-access-policy"
      values   = ["full"]
    }
  }

  statement {
    sid    = "SSMSendCommand"
    effect = "Allow"
    actions = [
      "ssm:SendCommand",
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ssm:*:*:managed-instance/*",
      "arn:aws:ssm:*:*:document/AWSSSO-CreateSSOUser"
    ]
    condition {
      test     = "BoolIfExists"
      variable = "ssm:SessionDocumentAccessCheck"
      values   = ["true"]
    }
    condition {
      test     = "StringEqualsIfExists"
      variable = "ssm:resourceTag/instance-access-policy"
      values   = ["full"]
    }
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
  statement {
    sid    = "ABACEc2Deny"
    effect = "Deny"
    actions = [
      "*"
    ]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringNotLike"
      variable = "aws:PrincipalTag/github_team"

      values = [
        "*:$${aws:ResourceTag/Owner}:*",
        "$${aws:ResourceTag/Owner}:*",
        "*:$${aws:ResourceTag/Owner}"
      ]
    }
    condition {
      test     = "Null"
      variable = "aws:ResourceTag/Owner"
      values = [
        "False"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"

      values = [
        local.environment_management.account_ids["core-shared-services-production"]
      ]
    }
  }
  statement {
    sid    = "databaseAllowNull"
    effect = "Allow"
    actions = [
      "application-autoscaling:ListTagsForResource",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:StartInstanceRefresh",
      "autoscaling:UpdateAutoScalingGroup",
      "aws-marketplace:ViewSubscriptions",
      "ds:*Snapshot*",
      "ds:*Tags*",
      "ds:ResetUserPassword",
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Connect",
      "ec2:CopyImage",
      "ec2:CopySnapshot",
      "ec2:CreateImage",
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcs",
      "ec2:DetachVolume",
      "ec2:GetConsoleOutput",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RebootInstances",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RunInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ecs:DescribeServices",
      "ecs:ListServices",
      "ecs:UpdateService",
      "identitystore:DescribeUser",
      "kms:Decrypt*",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "rds:CopyDBClusterSnapshot",
      "rds:CopyDBSnapshot",
      "rds:CreateDBClusterSnapshot",
      "rds:CreateDBSnapshot",
      "rds:RebootDB*",
      "rhelkb:GetRhelURL",
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecret*",
      "ssm:*",
      "ssm-guiconnect:*",
      "sso:ListDirectoryAssociations",
      "support:*",
      "support-console:*"
    ]

    resources = ["*"]

  }
  statement {
    sid    = "SecretsManagerPut"
    effect = "Allow"
    actions = [
      "secretsmanager:PutSecretValue",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "secretsmanager:ResourceTag/instance-management-policy"
      values   = ["full"]
    }
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
#trivy:ignore:AVD-AWS-0345: Required for reporting operations access to S3 resources
data "aws_iam_policy_document" "reporting-operations" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_107
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356:
  statement {
    sid    = "reportingOperationsAllow"
    effect = "Allow"
    actions = [
      "dms:DescribeReplicationInstances",
      "dms:DescribeReplicationTasks",
      "dms:ModifyReplicationTask",
      "dms:StartReplicationTaskAssessmentRun",
      "dms:StartReplicationTask",
      "dms:StopReplicationTask",
      "dms:TestConnection",
      "dms:ReloadTables",
      "dms:RebootReplicationInstance",
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
      "glue:StartTrigger",
      "glue:StopTrigger",
      "glue:GetConnection",
      "glue:GetConnections",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
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
      "states:RedriveExecution",
      "scheduler:UpdateSchedule",
      "kinesisanalytics:StartApplication",
      "kinesisanalytics:StopApplication",
      "kinesisanalytics:CreateApplicationSnapshot",
      "kinesisanalytics:List*",
      "kinesisanalytics:Describe*",
      "kinesisanalytics:DiscoverInputSchema",
      "kinesisanalytics:RollbackApplication",
      "lambda:InvokeFunction"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }

  statement {
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DeleteSecret",
      "secretsmanager:TagResource"
    ]
    resources = ["arn:aws:secretsmanager:*:*:sqlworkbench!*"]
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

resource "aws_iam_policy" "s3_upload_policy" {
  provider = aws.workspace
  name     = "s3_upload_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.s3_upload_policy_document.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "s3_upload_policy_document" {
  statement {
    sid    = "AllowS3Upload"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetBucketOwnershipControls",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:PutObject"
    ]
    resources = [
      data.aws_s3_bucket.mod_platform_artefact.arn,
      "${data.aws_s3_bucket.mod_platform_artefact.arn}/*"
    ]
  }
  statement {
    #checkov:skip=CKV_AWS_111 ListAliases only supports a wildcard
    #checkov:skip=CKV_AWS_356 ListAliases only supports a wildcard
    sid    = "AllowS3UploadKms"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "kms:DescribeKey",
      "kms:ListAliases"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ssm_session_access" {
  provider = aws.workspace
  name     = "ssm_session_access_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.ssm_session_access.json
}

data "aws_iam_policy_document" "ssm_session_access" {
  #checkov:skip=CKV_AWS_111 Needs to access multiple resources and the policy is attached to a role that is scoped to a specific account
  #checkov:skip=CKV_AWS_356 Needs to access multiple resources and the policy is attached to a role that is scoped to a specific account

  statement {
    sid     = "AllowStartSessionOnEC2Instances"
    effect  = "Allow"
    actions = ["ssm:StartSession"]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSessionToRemoteHost",
      "arn:aws:ssm:*:*:document/SSM-SessionManagerRunShell"
    ]
  }

  statement {
    sid    = "AllowManageOwnSessions"
    effect = "Allow"
    actions = [
      "ssm:TerminateSession",
      "ssm:ResumeSession"
    ]
    resources = ["arn:aws:ssm:*:*:session/$${aws:username}-*"]
  }

  statement {
    sid    = "AllowDescribeForSessionManagement"
    effect = "Allow"
    actions = [
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus",
      "ssm:DescribeInstanceProperties",
      "ec2:DescribeInstances"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "data_scientist" {
  provider = aws.workspace
  name     = "data_scientist_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.data_scientist.json
}

data "aws_iam_policy_document" "data_scientist" {
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_356 
  statement {
    sid    = "EventBridgeAndSchedulerPermissions"
    effect = "Allow"
    actions = [
      "events:DeleteRule",
      "events:DescribeApiDestination",
      "events:DescribeArchive",
      "events:DescribeConnection",
      "events:DescribeEndpoint",
      "events:DescribeEventBus",
      "events:DescribeEventSource",
      "events:DescribeReplay",
      "events:DescribeRule",
      "events:ListApiDestinations",
      "events:ListArchives",
      "events:ListConnections",
      "events:ListEndpoints",
      "events:ListEventBuses",
      "events:ListEventSources",
      "events:ListReplays",
      "events:ListRuleNamesByTarget",
      "events:ListRules",
      "events:ListTargetsByRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
      "events:TestEventPattern",
      "pipes:DescribePipe",
      "pipes:ListPipes",
      "pipes:ListTagsForResource",
      "scheduler:GetSchedule",
      "scheduler:GetScheduleGroup",
      "scheduler:ListScheduleGroups",
      "scheduler:ListSchedules",
      "scheduler:ListTagsForResource",
      "schemas:DescribeCodeBinding",
      "schemas:DescribeDiscoverer",
      "schemas:DescribeRegistry",
      "schemas:DescribeSchema",
      "schemas:ExportSchema",
      "schemas:GetCodeBindingSource",
      "schemas:GetDiscoveredSchema",
      "schemas:GetResourcePolicy",
      "schemas:ListDiscoverers",
      "schemas:ListRegistries",
      "schemas:ListSchemaVersions",
      "schemas:ListSchemas",
      "schemas:ListTagsForResource",
      "schemas:SearchSchemas",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RedshiftServerlessAdditionalPermissions"
    effect = "Allow"
    actions = [
      "redshift-serverless:GetNamespace",
      "redshift-serverless:GetWorkgroup"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3ListBucketsAccess"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }
}

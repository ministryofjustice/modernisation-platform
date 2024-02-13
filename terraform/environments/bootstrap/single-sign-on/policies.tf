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
      "arn:aws:iam::*:role/read-log-records",
      "arn:aws:iam::*:role/member-delegation-read-only",
      "arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:role/member-shared-services",
      "arn:aws:iam::${local.modernisation_platform_account.id}:role/modernisation-account-limited-read-member-access",
      "arn:aws:iam::${local.modernisation_platform_account.id}:role/modernisation-account-terraform-state-member-access"
    ]
  }
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

# data engineerin policy (developer + glue + some athena)
resource "aws_iam_policy" "data_engineering" {
  provider = aws.workspace
  name     = "data_engineering_policy"
  path     = "/"
  policy   = data.aws_iam_policy_document.data_engineering_additional.json
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
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "aws-marketplace:ViewSubscriptions",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:PutDashboard",
      "cloudwatch:ListMetrics",
      "cloudwatch:DeleteDashboards",
      "cloudwatch:ListTagsForResource",
      "codebuild:ImportSourceCredentials",
      "codebuild:PersistOAuthToken",
      "cur:DescribeReportDefinitions",
      "ds:*Tags*",
      "ds:*Snapshot*",
      "ds:ResetUserPassword",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:RebootInstances",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyVolume",
      "ec2:ModifySnapshotAttribute",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateVolume",
      "ec2:CopySnapshot",
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:CreateTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2-instance-connect:SendSerialConsoleSSHPublicKey",
      "ecr:BatchDeleteImage",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:ListTagsForResource",
      "events:DisableRule",
      "events:EnableRule",
      "identitystore:DescribeUser",
      "kms:Decrypt*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "lambda:InvokeFunction",
      "lambda:UpdateFunctionCode",
      "rds:AddTagsToResource",
      "rds:CopyDBSnapshot",
      "rds:CopyDBClusterSnapshot",
      "rds:CreateDBSnapshot",
      "rds:CreateDBClusterSnapshot",
      "rds:ModifyDBSnapshotAttribute",
      "rds:RestoreDBInstanceToPointInTime",
      "rds:RebootDB*",
      "rhelkb:GetRhelURL",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:RestoreObject",
      "s3:*StorageLens*",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:RestoreSecret",
      "secretsmanager:RotateSecret",
      "servicequotas:*",
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
      "glue:BatchCreatePartition",
      "glue:BatchDeletePartition",
      "glue:BatchDeleteTable",
      "glue:CreateDatabase",
      "glue:CreatePartition",
      "glue:CreateTable",
      "glue:DeleteDatabase",
      "glue:DeletePartition",
      "glue:DeleteTable",
      "glue:UpdateDatabase",
      "glue:UpdatePartition",
      "glue:UpdateTable",
      "glue:CreateUserDefinedFunction",
      "glue:DeleteUserDefinedFunction",
      "glue:UpdateUserDefinedFunction",
      "glue:BatchStopJobRun",
      "glue:CreateJob",
      "glue:DeleteJob",
      "glue:Get*",
      "glue:StartJobRun",
      "glue:StopJobRun",
      "glue:UpdateJob",
      "glue:List*",
      "glue:BatchGetJobs",
      "glue:StopTrigger",
      "glue:UpdateTrigger",
      "glue:StartTrigger",
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

resource "aws_iam_policy" "powerbi_user" {
  provider = aws.workspace
  name     = "powerbi_user"
  path     = "/"
  policy   = data.aws_iam_policy_document.powerbi_user_additional.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "powerbi_user_additional" {
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_107
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_110
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  override_policy_documents = [data.aws_iam_policy_document.data_engineering_additional.json]
  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::mojap-derived-tables/dev/run_artefacts/*",
      "arn:aws:s3:::mojap-derived-tables/dev/models/domain_name=risk/*",
      "arn:aws:s3:::mojap-derived-tables/seeds/*",
      "arn:aws:s3:::alpha-everyone/*",
      "arn:aws:s3:::dbt-query-dump/*",
      "arn:aws:s3:::mojap-manage-offences/ho-offence-codes/dev/*",
      "arn:aws:s3:::mojap-derived-tables/dev/models/domain_name=general/*",
      "arn:aws:s3:::mojap-derived-tables/*__dbt_tmp/*",
      "arn:aws:s3:::alpha-postcodes/database/postcodes/*",
      "arn:aws:s3:::alpha-lookup-cjsq/lookup_offence_raw/*",
      "arn:aws:s3:::mojap-derived-tables/prod/models/domain_name=general/*",
      "arn:aws:s3:::moj-reg-dev-curated/hmpps-assess-risks-and-needs-dev/data/*",
      "arn:aws:s3:::alpha-data-linking/v4/products/internal/*",
      "arn:aws:s3:::moj-reg-dev-curated/data-eng-uploader-dev/data/*",
      "arn:aws:s3:::alpha-cjsm-logs-data/api_test/production/processed/pass/*",
      "arn:aws:s3:::alpha-postcodes/database/names/*",
      "arn:aws:s3:::mojap-derived-tables/prod/run_artefacts/*",
      "arn:aws:s3:::moj-reg-dev-curated/hmpps-interventions-dev/data/*",
      "arn:aws:s3:::alpha-lookup-cjsq/lookup_offence/*",
      "arn:aws:s3:::alpha-lookup-cjsq/lookup_court_disposals/*",
      "arn:aws:s3:::alpha-data-linking-anonymised/v4/products/internal/*",
      "arn:aws:s3:::mojap-derived-tables/prod/models/domain_name=risk/*",
      "arn:aws:s3:::alpha-psr-discovery-work/*",
      "arn:aws:s3:::alpha-interventions-discovery-ds/*",
      "arn:aws:s3:::alpha-segmentation-adhoc/*",
      "arn:aws:s3:::alpha-app-commuter-sandbox/*",
      "arn:aws:s3:::alpha-app-interventions/*",
      "arn:aws:s3:::alpha-segmentation/*",
      "arn:aws:s3:::alpha-segmentation-2020alpha-segmentation-2020/restricted_share//*",
      "arn:aws:s3:::alpha-segmentation-2020restricted_share//*",
      "arn:aws:s3:::alpha-segmentation-2020restricted_share/*/*",
      "arn:aws:s3:::alpha-segmentation-2020restricted_share/*",
      "arn:aws:s3:::alpha-segmentation-2020/*",
      "arn:aws:s3:::alpha-nextgenaccreditedevaluation/*",
      "arn:aws:s3:::alpha-app-occupeye-automation/*",
      "arn:aws:s3:::alpha-app-matrixbooking/*",
      "arn:aws:s3:::alpha-dag-matrix/*",
      "arn:aws:s3:::alpha-dag-occupeye/*",
      "arn:aws:s3:::alpha-data-science-risk/*",
      "arn:aws:s3:::alpha--people-survey/*",
      "arn:aws:s3:::alpha-accredited-programmes-review-2021/*",
      "arn:aws:s3:::alpha-probation-data-room/*",
      "arn:aws:s3:::alpha-app-segmentation-tool-probation/*",
      "arn:aws:s3:::alpha-hr-dataproject/Input Data/Pay Element Lists/*",
      "arn:aws:s3:::alpha-hr-dataproject/Input Data/Remuneration Data/Remuneration Tool Data/*"
    ]
    sid = "readonly"
  }
  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::alpha-cjsm-logs-data",
      "arn:aws:s3:::alpha-data-linking",
      "arn:aws:s3:::alpha-data-linking-anonymised",
      "arn:aws:s3:::alpha-everyone",
      "arn:aws:s3:::alpha-lookup-cjsq",
      "arn:aws:s3:::alpha-postcodes",
      "arn:aws:s3:::dbt-query-dump",
      "arn:aws:s3:::moj-reg-dev-curated",
      "arn:aws:s3:::mojap-derived-tables",
      "arn:aws:s3:::mojap-manage-offences",
      "arn:aws:s3:::alpha-probation-data-room",
      "arn:aws:s3:::alpha-psr-discovery-work",
      "arn:aws:s3:::alpha-interventions-discovery-ds",
      "arn:aws:s3:::alpha-segmentation-adhoc",
      "arn:aws:s3:::alpha-app-commuter-sandbox",
      "arn:aws:s3:::alpha-app-segmentation-tool-probation",
      "arn:aws:s3:::alpha-app-interventions",
      "arn:aws:s3:::alpha-segmentation",
      "arn:aws:s3:::alpha-segmentation-2020",
      "arn:aws:s3:::alpha-nextgenaccreditedevaluation",
      "arn:aws:s3:::alpha-app-occupeye-automation",
      "arn:aws:s3:::alpha-app-matrixbooking",
      "arn:aws:s3:::alpha-dag-matrix",
      "arn:aws:s3:::alpha-dag-occupeye",
      "arn:aws:s3:::alpha-data-science-risk",
      "arn:aws:s3:::alpha--people-survey",
      "arn:aws:s3:::alpha-hr-dataproject",
      "arn:aws:s3:::alpha-accredited-programmes-review-2021",
      "arn:aws:s3:::alpha-athena-query-dump",
      "arn:aws:s3:::mojap-athena-query-dump"
    ]
    sid = "list"
  }
  statement {
    sid       = "ssm"
    resources = ["*"]
    effect    = "Allow"
    actions = [
      "ssm:*"
    ]
  }
}
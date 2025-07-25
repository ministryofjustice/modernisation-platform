# read only role for collaborators
module "collaborator_readonly_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" || local.account_data.account-type == "core" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-roles?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  max_session_duration = 43200
  # Read-only role
  create_readonly_role       = true
  readonly_role_name         = "read-only"
  readonly_role_requires_mfa = true

  # Allow created users to assume these roles
  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]
}

data "aws_iam_policy" "common_policy" {
  name = "common_policy"
}

# security audit role for collaborators
module "collaborator_security_audit_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" || local.account_data.account-type == "core" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  max_session_duration = 43200

  create_role       = true
  role_name         = "security-audit"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/SecurityAudit"
  ]

  # Allow created users to assume these roles
  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]
}

# developer role for collaborators
module "collaborator_developer_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "developer"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    data.aws_iam_policy.developer.arn,
    data.aws_iam_policy.common_policy.arn,
  ]
  number_of_custom_role_policy_arns = 3
}

data "aws_iam_policy" "developer" {
  name = "developer_policy"
}

# Collaborator Sandbox role
module "collaborator_sandbox_role" {
  # checkov:skip=CKV_TF_1:

  count  = (local.account_data.account-type == "member" && (local.application_environment == "development" || terraform.workspace == "youth-justice-app-framework-preproduction")) ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "sandbox"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    data.aws_iam_policy.sandbox.arn,
    data.aws_iam_policy.common_policy.arn,
    data.aws_iam_policy.bedrock.arn,
  ]
  number_of_custom_role_policy_arns = 3
}

data "aws_iam_policy" "sandbox" {
  name = "sandbox_policy"
}

data "aws_iam_policy" "bedrock" {
  name = "bedrock_policy"
}
# Collaborator Migration role
module "collaborator_migration_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "migration"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSApplicationMigrationFullAccess",
    "arn:aws:iam::aws:policy/AWSDataSyncFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/ServerMigrationConnector",
    "arn:aws:iam::aws:policy/AWSApplicationMigrationEC2Access",
    data.aws_iam_policy.migration.arn,
    data.aws_iam_policy.developer.arn,
    data.aws_iam_policy.common_policy.arn,
  ]
  number_of_custom_role_policy_arns = 9
}

data "aws_iam_policy" "migration" {
  name = "migration_policy"
}

# Collaborator Instance Access role
module "collaborator_instance_access_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "instance-access"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    data.aws_iam_policy.instance-access.arn,
    data.aws_iam_policy.common_policy.arn,
  ]
  number_of_custom_role_policy_arns = 3
}

data "aws_iam_policy" "instance-access" {
  name = "instance_access_policy"
}

# Collaborator Database Management role
module "collaborator_database_mgmt_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "instance-management"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    data.aws_iam_policy.instance-management.arn,
    data.aws_iam_policy.common_policy.arn,
  ]
  number_of_custom_role_policy_arns = 3
}

data "aws_iam_policy" "instance-management" {
  name = "instance_management_policy"
}

# fleet-manager role for collaborators
module "collaborator_fleet_manager_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "fleet-manager"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    data.aws_iam_policy.fleet_manager.arn,
    data.aws_iam_policy.common_policy.arn,
  ]
  number_of_custom_role_policy_arns = 3
}

data "aws_iam_policy" "fleet_manager" {
  name = "fleet_manager_policy"
}

# s3-upload role for collaborators
module "collaborator_s3_upload_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "s3-upload"
  role_requires_mfa = true

  custom_role_policy_arns = [
    data.aws_iam_policy.s3_upload.arn
  ]
  number_of_custom_role_policy_arns = 1
}

data "aws_iam_policy" "s3_upload" {
  name = "s3_upload_policy"
}

# Collaborator Instance Access role
module "collaborator_platform_engineer_admin_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "platform-engineer-admin"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    data.aws_iam_policy.platform_engineer_admin.arn,
    data.aws_iam_policy.common_policy.arn,
  ]
  number_of_custom_role_policy_arns = 3
}

data "aws_iam_policy" "platform_engineer_admin" {
  name = "platform_engineer_admin_policy"
}

# Collaborator Reporting-Operations role
module "collaborator_reporting_operations_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "reporting-operations"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    data.aws_iam_policy.reporting_operations.arn,
    data.aws_iam_policy.common_policy.arn,
  ]
  number_of_custom_role_policy_arns = 3
}

data "aws_iam_policy" "reporting_operations" {
  name = "reporting_operations_policy"
}

# SSM Session Access role
module "collaborator_ssm_session_access_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "ssm-session-access"
  role_requires_mfa = true

  custom_role_policy_arns = [
    data.aws_iam_policy.ssm_session_access.arn
  ]
  number_of_custom_role_policy_arns = 1
}

data "aws_iam_policy" "ssm_session_access" {
  name = "ssm_session_access_policy"
}


# Quicksight admin role
module "collaborator_quicksight_admin_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "quicksight-admin-access"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    data.aws_iam_policy.quicksight_administrator.arn,
    data.aws_iam_policy.common_policy.arn,
  ]
  number_of_custom_role_policy_arns = 3
}

data "aws_iam_policy" "quicksight_administrator" {
  name = "quicksight_administrator_policy"
}

# Data Scientist role

module "collaborator_data_scientist_role" {
  # checkov:skip=CKV_TF_1:

  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=de95e21a3bc51cd3a44b3b95a4c2f61000649ebb" # v5.39.1

  trusted_role_arns = [
    data.aws_ssm_parameter.modernisation_platform_account_id.value
  ]

  create_role       = true
  role_name         = "data-scientist"
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonRedshiftQueryEditorV2FullAccess",
    data.aws_iam_policy.data_scientist.arn,
  ]
  number_of_custom_role_policy_arns = 2
}

data "aws_iam_policy" "data_scientist" {
  name = "data_scientist_policy"
}
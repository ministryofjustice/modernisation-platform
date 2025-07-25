##################################################
# Modernisation Platform SSO permision sets #
##################################################

# Modernisation Platform developer
resource "aws_ssoadmin_permission_set" "modernisation_platform_developer" {
  provider         = aws.sso-management
  name             = "modernisation-platform-developer"
  description      = "Modernisation Platform: developer tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_developer" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_developer.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_developer" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_developer.arn
  customer_managed_policy_reference {
    name = "developer_policy"
    path = "/"
  }
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_developer_common" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_developer.arn
  customer_managed_policy_reference {
    name = "common_policy"
    path = "/"
  }
}

# Modernisation Platform data engineer
resource "aws_ssoadmin_permission_set" "modernisation_platform_data_engineer" {
  provider         = aws.sso-management
  name             = "modernisation-platform-data-eng"
  description      = "Modernisation Platform: data engineer tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_data_engineer" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_engineer.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_data_engineer" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_engineer.arn
  customer_managed_policy_reference {
    name = "data_engineering_policy"
    path = "/"
  }
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_data_engineer_common" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_engineer.arn
  customer_managed_policy_reference {
    name = "common_policy"
    path = "/"
  }
}
resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_data_engineer_developer_additional" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_engineer.arn
  customer_managed_policy_reference {
    name = "developer_policy"
    path = "/"
  }
}

# Modernisation Platform Managed Workloads for Apache Airflow user
resource "aws_ssoadmin_permission_set" "modernisation_platform_data_mwaa_user" {
  provider         = aws.sso-management
  name             = "modernisation-platform-mwaa-user"
  description      = "Modernisation Platform: data engineering mwaa user"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_data_mwaa_user" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_mwaa_user.arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "modernisation_platform_data_mwaa_user" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  inline_policy      = data.aws_iam_policy_document.modernisation_platform_data_mwaa_user.json
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_mwaa_user.arn
}

data "aws_iam_policy_document" "modernisation_platform_data_mwaa_user" {
  statement {
    sid     = "MWAAUIUserAccess"
    effect  = "Allow"
    actions = ["airflow:CreateWebLoginToken"]
    resources = [
      "arn:aws:airflow:eu-west-2:${local.environment_management.account_ids["analytical-platform-compute-development"]}:role/development/User",
      "arn:aws:airflow:eu-west-2:${local.environment_management.account_ids["analytical-platform-compute-test"]}:role/test/User",
      "arn:aws:airflow:eu-west-2:${local.environment_management.account_ids["analytical-platform-compute-production"]}:role/production/User",
    ]
  }
  statement {
    sid    = "SecretsManagerKMSAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = formatlist("arn:aws:kms:%s:${local.environment_management.account_ids["analytical-platform-data-production"]}:key/mrk-15afdf54bde745d3b583a6818ee6c154", ["eu-west-1", "eu-west-2"])
  }
  statement {
    sid       = "SecretsManagerAccess"
    effect    = "Allow"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]
  }
  statement {
    sid    = "SecretsManagerSecretsAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = formatlist("arn:aws:secretsmanager:%s:${local.environment_management.account_ids["analytical-platform-data-production"]}:secret:/airflow/*", ["eu-west-1", "eu-west-2"])
  }
}

# Modernisation Platform sandbox
resource "aws_ssoadmin_permission_set" "modernisation_platform_sandbox" {
  provider         = aws.sso-management
  name             = "modernisation-platform-sandbox"
  description      = "Modernisation Platform: sandbox tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_sandbox" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_sandbox.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_sandbox" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_sandbox.arn
  customer_managed_policy_reference {
    name = "sandbox_policy"
    path = "/"
  }
}
resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_sandox_bedrock" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_sandbox.arn
  customer_managed_policy_reference {
    name = "bedrock_policy"
    path = "/"
  }
}
resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_sandox_common" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_sandbox.arn
  customer_managed_policy_reference {
    name = "common_policy"
    path = "/"
  }
}

# Modernisation Platform migration
resource "aws_ssoadmin_permission_set" "modernisation_platform_migration" {
  provider         = aws.sso-management
  name             = "modernisation-platform-migration"
  description      = "Modernisation Platform: migration tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_migration" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_migration_ec2" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_migration_mgn" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_migration_datasync" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSDataSyncFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_migration_servermigration" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ServerMigrationConnector"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_migration" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
  customer_managed_policy_reference {
    name = "migration_policy"
    path = "/"
  }
}
resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_data_migration_developer_additional" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
  customer_managed_policy_reference {
    name = "developer_policy"
    path = "/"
  }
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_migration_common" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
  customer_managed_policy_reference {
    name = "common_policy"
    path = "/"
  }
}
# Modernisation Platform reporting operations
resource "aws_ssoadmin_permission_set" "modernisation_platform_reporting_operations" {
  provider         = aws.sso-management
  name             = "mp-reporting-operations"
  description      = "Modernisation Platform: reporting-operations tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_reporting_operations" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_reporting_operations.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_reporting_operations" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_reporting_operations.arn
  customer_managed_policy_reference {
    name = "reporting_operations_policy"
    path = "/"
  }
}
resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_reporting_common" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_reporting_operations.arn
  customer_managed_policy_reference {
    name = "common_policy"
    path = "/"
  }
}

# Modernisation Platform instance-access role
resource "aws_ssoadmin_permission_set" "modernisation_platform_instance_access" {
  provider         = aws.sso-management
  name             = "mp-instance-access"
  description      = "Modernisation Platform: instance-access"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_instance_access" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_instance_access.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_instance_access" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_instance_access.arn
  customer_managed_policy_reference {
    name = "instance_access_policy"
    path = "/"
  }
}

# Modernisation Platform instance-management role
resource "aws_ssoadmin_permission_set" "modernisation_platform_instance_management" {
  provider         = aws.sso-management
  name             = "mp-instance-management"
  description      = "Modernisation Platform: instance-management"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_instance_management" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_instance_management.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_instance_management" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_instance_management.arn
  customer_managed_policy_reference {
    name = "instance_management_policy"
    path = "/"
  }
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_instance_management_common" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_instance_management.arn
  customer_managed_policy_reference {
    name = "common_policy"
    path = "/"
  }
}

# Modernisation Platform Managed PowerBI user role for Analytical Platform
resource "aws_ssoadmin_permission_set" "modernisation_platform_powerbi_user" {
  provider         = aws.sso-management
  name             = "modernisation-platform-powerbi"
  description      = "Modernisation Platform: Analytcal PowerBI"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_powerbi_user" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_powerbi_user.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_powerbi_user" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_powerbi_user.arn
  customer_managed_policy_reference {
    name = "powerbi_user"
    path = "/"
  }
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_powerbi_common" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_powerbi_user.arn
  customer_managed_policy_reference {
    name = "common_policy"
    path = "/"
  }
}

# Modernisation Platform fleet-manager role
resource "aws_ssoadmin_permission_set" "modernisation_platform_fleet_manager" {
  provider         = aws.sso-management
  name             = "mp-fleet-manager"
  description      = "Modernisation Platform: fleet-manager"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_fleet_manager" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_fleet_manager.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_fleet_manager" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_fleet_manager.arn
  customer_managed_policy_reference {
    name = "fleet_manager_policy"
    path = "/"
  }
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_fleet_manager_common" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_fleet_manager.arn
  customer_managed_policy_reference {
    name = "common_policy"
    path = "/"
  }
}


# Modernisation Platform QuickSight Administrator
resource "aws_ssoadmin_permission_set" "modernisation_platform_quicksight_admin" {
  provider         = aws.sso-management
  name             = "modernisation-platform-qs-admin"
  description      = "Modernisation Platform: quicksight admin tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_quicksight_admin" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_quicksight_admin.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_quicksight_admin" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_quicksight_admin.arn
  customer_managed_policy_reference {
    name = "quicksight_administrator_policy"
    path = "/"
  }
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_quicksight_admin_common" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_quicksight_admin.arn
  customer_managed_policy_reference {
    name = "common_policy"
    path = "/"
  }
}

# Modernisation Platform platform-engineer-admin role
resource "aws_ssoadmin_permission_set" "modernisation_platform_platform_engineer_admin" {
  provider         = aws.sso-management
  name             = "platform-engineer-admin"
  description      = "Modernisation Platform: platform-engineer-admin"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_platform_engineer_admin" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_platform_engineer_admin.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_platform_engineer_admin" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_platform_engineer_admin.arn
  customer_managed_policy_reference {
    name = "platform_engineer_admin_policy"
    path = "/"
  }
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_platform_engineer_admin_common" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_platform_engineer_admin.arn
  customer_managed_policy_reference {
    name = "common_policy"
    path = "/"
  }
}

# Modernisation Platform SSM Session Access role
resource "aws_ssoadmin_permission_set" "modernisation_platform_ssm_session_access" {
  provider         = aws.sso-management
  name             = "mp-ssm-session-access"
  description      = "Modernisation Platform: ssm-session-access"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_ssm_session_access" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_ssm_session_access.arn
  customer_managed_policy_reference {
    name = "ssm_session_access_policy"
    path = "/"
  }
}

# Modernisation Platform Data Scientist role

resource "aws_ssoadmin_permission_set" "modernisation_platform_data_scientist" {
  provider         = aws.sso-management
  name             = "mp-data-scientist"
  description      = "Modernisation Platform: data-scientist"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_data_scientist_redshift_access" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftQueryEditorV2FullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_scientist.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_data_scientist" {
  provider           = aws.sso-management
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_scientist.arn
  customer_managed_policy_reference {
    name = "data_scientist_policy"
    path = "/"
  }
}
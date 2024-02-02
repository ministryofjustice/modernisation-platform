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
    actions = [
      "airflow:CreateWebLoginToken"
    ]
    resources = ["arn:aws:airflow:*:*:role/*/User"]
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

# Modernisation Platform Managed PowerBI user role for Analytical Platform
resource "aws_ssoadmin_permission_set" "modernisation_platform_powerbi_user" {
  provider         = aws.sso-management
  name             = "modernisation-platform-powerbi-user"
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

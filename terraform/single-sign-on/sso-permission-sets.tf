# # Get AWS SSO instances. Note that this returns a list,
# # although AWS SSO only supports singular SSO instances.
data "aws_ssoadmin_instances" "default" {
  provider = aws.sso-management
}

locals {
  sso_instance_arn      = coalesce(data.aws_ssoadmin_instances.default.arns...)
  sso_identity_store_id = coalesce(data.aws_ssoadmin_instances.default.identity_store_ids...)

}

##################################################
# Modernisation Platform specific permision sets #
##################################################

# Modernisation Platform developer
resource "aws_ssoadmin_permission_set" "modernisation_platform_developer" {
  name             = "modernisation-platform-developer"
  description      = "Modernisation Platform: developer tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_developer" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_developer.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_developer" {
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_developer.arn
  customer_managed_policy_reference {
    name = "developer_policy"
    path = "/"
  }
}

# Modernisation Platform data engineer
resource "aws_ssoadmin_permission_set" "modernisation_platform_data_engineer" {
  name             = "modernisation-platform-data-eng"
  description      = "Modernisation Platform: data engineer tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_data_engineer" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_engineer.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_data_engineer" {
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_engineer.arn
  customer_managed_policy_reference {
    name = "data_engineering_policy"
    path = "/"
  }
}

# Modernisation Platform data engineer
resource "aws_ssoadmin_permission_set" "modernisation_platform_data_mwaa_user" {
  name             = "modernisation-platform-mwaa-user"
  description      = "Modernisation Platform: data engineering mwaa user"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_data_mwaa_user" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_data_mwaa_user.arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "modernisation_platform_data_mwaa_user" {
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
  name             = "modernisation-platform-sandbox"
  description      = "Modernisation Platform: sandbox tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_sandbox" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_sandbox.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_sandbox" {
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_sandbox.arn
  customer_managed_policy_reference {
    name = "sandbox_policy"
    path = "/"
  }
}

# Modernisation Platform migration
resource "aws_ssoadmin_permission_set" "modernisation_platform_migration" {
  name             = "modernisation-platform-migration"
  description      = "Modernisation Platform: migration tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_migration" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_migration_ec2" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_migration_mgn" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_migration_datasync" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSDataSyncFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_migration_servermigration" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ServerMigrationConnector"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_migration" {
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
  customer_managed_policy_reference {
    name = "migration_policy"
    path = "/"
  }
}

# Modernisation Platform reporting operations
resource "aws_ssoadmin_permission_set" "modernisation_platform_reporting_operations" {
  name             = "mp-reporting-operations"
  description      = "Modernisation Platform: reporting-operations tenancy"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_reporting_operations" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_reporting_operations.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_reporting_operations" {
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_reporting_operations.arn
  customer_managed_policy_reference {
    name = "reporting_operations_policy"
    path = "/"
  }
}

# Modernisation Platform engineer
# This role is designed to be used as an alternative to a full on admin role / read only role when trouble shooting MP accounts
# Currently this is just readonly plus the ability to create support tickets, but potential we could add more permissions in here if it reduces admin role or superadmin usage
resource "aws_ssoadmin_permission_set" "modernisation_platform_engineer" {
  name             = "ModernisationPlatformEngineer"
  description      = "Modernisation Platform: engineer troubleshooting role"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_engineer" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_engineer.arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "modernisation_platform_engineer" {
  instance_arn       = local.sso_admin_instance_arn
  inline_policy      = data.aws_iam_policy_document.modernisation_platform_engineer.json
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_engineer.arn
}

data "aws_iam_policy_document" "modernisation_platform_engineer" {
  statement {
    actions = [
      "support:*"
    ]
    resources = ["*"]
  }
}


# Modernisation Platform instance-management role
resource "aws_ssoadmin_permission_set" "modernisation_platform_instance_management" {
  name             = "mp-instance-management"
  description      = "Modernisation Platform: instance-management"
  instance_arn     = local.sso_admin_instance_arn
  session_duration = "PT8H"
  tags             = {}
}

resource "aws_ssoadmin_managed_policy_attachment" "modernisation_platform_instance_management" {
  instance_arn       = local.sso_admin_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_instance_management.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "modernisation_platform_instance_management" {
  instance_arn       = local.sso_admin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.modernisation_platform_instance_management.arn
  customer_managed_policy_reference {
    name = "instance_management_policy"
    path = "/"
  }
}



# Get AWS SSO permission sets
# data "aws_ssoadmin_permission_set" "administrator" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "AdministratorAccess"
# }

# data "aws_ssoadmin_permission_set" "view-only" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "ViewOnlyAccess"
# }

# data "aws_ssoadmin_permission_set" "developer" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "modernisation-platform-developer"
# }

# data "aws_ssoadmin_permission_set" "platform_engineer" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "ModernisationPlatformEngineer"
# }

# data "aws_ssoadmin_permission_set" "sandbox" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "modernisation-platform-sandbox"
# }

# data "aws_ssoadmin_permission_set" "migration" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "modernisation-platform-migration"
# }

# data "aws_ssoadmin_permission_set" "instance-management" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "mp-instance-management"
# }

# data "aws_ssoadmin_permission_set" "security_audit" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "SecurityAudit"
# }

# data "aws_ssoadmin_permission_set" "read_only" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "ReadOnlyAccess"
# }

# data "aws_ssoadmin_permission_set" "data_engineer" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "modernisation-platform-data-eng"
# }

# data "aws_ssoadmin_permission_set" "reporting-operations" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "mp-reporting-operations"
# }

# data "aws_ssoadmin_permission_set" "mwaa_user" {
#   provider = aws.sso-management

#   instance_arn = local.sso_instance_arn
#   name         = "modernisation-platform-mwaa-user"
# }
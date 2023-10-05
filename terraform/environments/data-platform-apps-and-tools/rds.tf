module "openmetadata_airflow_rds" {

  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "openmetadata-airflow"

  engine               = "postgres"
  engine_version       = "15"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = "db.t4g.medium"

  ca_cert_identifier = "rds-ca-rsa2048-g1"

  allocated_storage     = 64
  max_allocated_storage = 256

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  username                    = "airflow"
  db_name                     = "airflow"
  manage_master_user_password = false
  password                    = random_password.openmetadata_airflow.result

  parameters = [
    {
      name  = "rds.force_ssl"
      value = 1
    },
    {
      name  = "log_statement"
      value = "all"
    },
    {
      name  = "log_hostname"
      value = 1
    },
    {
      name  = "log_connections"
      value = 1
    }
  ]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 7

  performance_insights_enabled = true

  create_monitoring_role          = true
  monitoring_role_use_name_prefix = true
  monitoring_role_name            = "openmetadata-airflow-rds-monitoring"
  monitoring_role_description     = "Enhanced Monitoring for Open Metadata Airflow RDS"
  monitoring_interval             = 30
  enabled_cloudwatch_logs_exports = ["general", "audit", "error", "postgresql"]

  skip_final_snapshot = true

  tags = local.tags
}

module "openmetadata_rds" {

  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "openmetadata"

  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.r6g.xlarge"

  ca_cert_identifier = "rds-ca-rsa2048-g1"

  allocated_storage     = 128
  max_allocated_storage = 512

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  username                    = "openmetadata"
  db_name                     = "openmetadata"
  manage_master_user_password = false
  password                    = random_password.openmetadata.result

  parameters = [
    {
      name  = "require_secure_transport"
      value = 1
    },
    {
      name  = "general_log"
      value = 1
    },
    {
      name  = "long_query_time"
      value = 10
    },
    {
      name  = "slow_query_log"
      value = 1
    },
    {
      // Required as per Open Metadata's documentation
      name  = "sort_buffer_size"
      value = 10485760
    }
    // TODO: Review adding more parameters, such as https://github.com/ministryofjustice/data-platform/blob/main/terraform/aws/analytical-platform-production/cluster/terraform.tfvars#L68-L84
  ]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 7

  apply_immediately = true

  performance_insights_enabled = true

  create_monitoring_role          = true
  monitoring_role_use_name_prefix = true
  monitoring_role_name            = "openmetadata-rds-monitoring"
  monitoring_role_description     = "Enhanced Monitoring for Open Metadata RDS"
  monitoring_interval             = 30
  enabled_cloudwatch_logs_exports = ["general", "audit", "error"]

  skip_final_snapshot = true

  tags = local.tags
}

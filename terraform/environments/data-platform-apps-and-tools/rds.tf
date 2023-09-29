module "airflow_rds" {

  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "openmetadata-airflow"

  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.t4g.medium"

  allocated_storage     = 64
  max_allocated_storage = 256

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  username                    = "airflow"
  db_name                     = "airflow"
  manage_master_user_password = false
  password                    = random_password.openmetadata_airflow.result

  performance_insights_enabled = true

  create_monitoring_role          = true
  monitoring_role_use_name_prefix = true
  monitoring_role_name            = "openmetadata-airflow-rds-monitoring"
  monitoring_role_description     = "Enhanced Monitoring for Open Metadata Airflow RDS"
  monitoring_interval             = 30

  skip_final_snapshot = true

  tags = local.tags
}
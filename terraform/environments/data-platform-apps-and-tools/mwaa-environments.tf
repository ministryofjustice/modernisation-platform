resource "aws_mwaa_environment" "main" {
  # checkov:skip=CKV_AWS_242:Suppressing message until decision on logging made
  # checkov:skip=CKV_AWS_243:Suppressing message until decision on logging made
  # checkov:skip=CKV_AWS_244:Suppressing message until decision on logging made
  name                            = local.environment_configuration.airflow_name
  airflow_version                 = local.environment_configuration.airflow_version
  environment_class               = local.environment_configuration.airflow_environment_class
  weekly_maintenance_window_start = local.environment_configuration.airflow_weekly_maintenance_window_start

  execution_role_arn = module.airflow_execution_role.iam_role_arn

  source_bucket_arn    = data.aws_s3_bucket.airflow.arn
  dag_s3_path          = local.environment_configuration.airflow_dag_s3_path
  requirements_s3_path = local.environment_configuration.airflow_requirements_s3_path

  max_workers = local.environment_configuration.airflow_max_workers
  min_workers = local.environment_configuration.airflow_min_workers
  schedulers  = local.environment_configuration.airflow_schedulers

  webserver_access_mode = local.environment_configuration.airflow_webserver_access_mode

  airflow_configuration_options = merge(
    local.environment_configuration.airflow_configuration_options,
    {
      "smtp.smtp_host"      = "email-smtp.${data.aws_region.current.name}.amazonaws.com"
      "smtp.smtp_port"      = 587
      "smtp.smtp_starttls"  = 1
      "smtp.smtp_user"      = module.airflow_iam_user.iam_access_key_id
      "smtp.smtp_password"  = module.airflow_iam_user.iam_access_key_ses_smtp_password_v4
      "smtp.smtp_mail_from" = "${local.environment_configuration.airflow_mail_from_address}@${local.environment_configuration.ses_domain_identity}"
    }
  )

  network_configuration {
    security_group_ids = [module.mwaa_security_group.security_group_id]
    subnet_ids         = slice(module.vpc.private_subnets, 0, 2)
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }

  tags = local.tags
}

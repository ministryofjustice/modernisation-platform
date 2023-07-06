locals {
  ses_domain_identity = "apps-tools.${local.environment}.data-platform.service.justice.gov.uk"

  airflow_name                  = "${local.application_name}-${local.environment}"
  airflow_dag_s3_path           = "dags/"
  airflow_requirements_s3_path  = "requirements.txt"
  airflow_webserver_access_mode = "PUBLIC_ONLY"
  airflow_mail_from_address     = "airflow@${local.ses_domain_identity}"

  environment_configuration = local.environment_configurations[local.environment]
  environment_configurations = {
    development = {
      airflow_s3_bucket         = "moj-data-platform-airflow-development20230627094128036000000001"
      airflow_version           = "2.4.3"
      airflow_environment_class = "mw1.small"
      airflow_max_workers       = 2
      airflow_min_workers       = 1
      airflow_schedulers        = 2
      airflow_configuration_options = {
        "webserver.warn_deployment_exposure" = 0
      }
      airflow_weekly_maintenance_window_start = "SAT:00:00"
      target_eks_cluster_arn                  = "arn:aws:eks:eu-west-1:525294151996:cluster/development-aWrhyc0m"
      target_aws_role_arn                     = "arn:aws:iam::525294151996:role/data-platform-apps-and-tools-development-airflow"
      vpc_cidr                                = "10.27.128.0/23"
      vpc_private_subnets                     = ["10.27.128.0/26", "10.27.128.64/26", "10.27.128.128/26"]
      vpc_public_subnets                      = ["10.27.129.0/26", "10.27.129.64/26", "10.27.129.128/26"]
      vpc_enable_nat_gateway                  = true
      vpc_one_nat_gateway_per_az              = false
    }
  }
}

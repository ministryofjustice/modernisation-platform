locals {
  airflow_name                  = "${local.application_name}-${local.environment}"
  airflow_dag_s3_path           = "dags/"
  airflow_requirements_s3_path  = "requirements.txt"
  airflow_webserver_access_mode = "PUBLIC_ONLY"
  airflow_mail_from_address     = "airflow@${local.environment_configuration.ses_domain_identity}"

  eks_cluster_name = "apps-tools-${local.environment}"

  environment_configuration = local.environment_configurations[local.environment]
  environment_configurations = {
    development = {
      airflow_s3_bucket         = "moj-data-platform-airflow-development20230627094128036000000001"
      airflow_version           = "2.6.3"
      airflow_environment_class = "mw1.medium"
      airflow_max_workers       = 2
      airflow_min_workers       = 1
      airflow_schedulers        = 2
      airflow_configuration_options = {
        "webserver.warn_deployment_exposure" = 0
      }
      airflow_weekly_maintenance_window_start = "SAT:00:00"
      target_eks_cluster_arn                  = "arn:aws:eks:eu-west-1:525294151996:cluster/development-aWrhyc0m"
      vpc_cidr                                = "10.26.128.0/21"
      vpc_private_subnets                     = ["10.26.130.0/23", "10.26.132.0/23", "10.26.134.0/23"]
      vpc_public_subnets                      = ["10.26.128.0/27", "10.26.128.32/27", "10.26.128.64/27"]
      vpc_database_subnets                    = ["10.26.128.96/27", "10.26.128.128/27", "10.26.128.160/27"]
      vpc_enable_nat_gateway                  = true
      vpc_one_nat_gateway_per_az              = false
      route53_zone                            = "apps-tools.development.data-platform.service.justice.gov.uk"
      ses_domain_identity                     = "apps-tools.development.data-platform.service.justice.gov.uk"
      eks_sso_access_role                     = "modernisation-platform-sandbox"
    }
    production = {
      airflow_s3_bucket         = "moj-data-platform-airflow-production20230908140747954800000002"
      airflow_version           = "2.6.3"
      airflow_environment_class = "mw1.large"
      airflow_max_workers       = 4
      airflow_min_workers       = 1
      airflow_schedulers        = 4
      airflow_configuration_options = {
        "webserver.warn_deployment_exposure" = 0
      }
      airflow_weekly_maintenance_window_start = "SAT:00:00"
      target_eks_cluster_arn                  = "arn:aws:eks:eu-west-1:525294151996:cluster/development-aWrhyc0m"
      vpc_cidr                                = "10.27.128.0/21"
      vpc_private_subnets                     = ["10.27.130.0/23", "10.27.132.0/23", "10.27.134.0/23"]
      vpc_public_subnets                      = ["10.27.128.0/27", "10.27.128.32/27", "10.27.128.64/27"]
      vpc_database_subnets                    = ["10.27.128.96/27", "10.27.128.128/27", "10.27.128.160/27"]
      vpc_enable_nat_gateway                  = true
      vpc_one_nat_gateway_per_az              = false
      route53_zone                            = "apps-tools.data-platform.service.justice.gov.uk"
      ses_domain_identity                     = "apps-tools.data-platform.service.justice.gov.uk"
      eks_sso_access_role                     = "modernisation-platform-developer"
    }
  }
}

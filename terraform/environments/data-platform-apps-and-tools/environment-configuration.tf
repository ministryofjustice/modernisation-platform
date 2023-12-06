locals {
  airflow_name              = "${local.application_name}-${local.environment}"
  environment_configuration = local.environment_configurations[local.environment]
  environment_configurations = {
    development = {
      /* Route53 */
      route53_zone = "apps-tools.development.data-platform.service.justice.gov.uk" // This is defined in modernisation-platform-environments

      /* SES */
      ses_domain_identity = "apps-tools.development.data-platform.service.justice.gov.uk" // This is defined in modernisation-platform-environments

      /* VPC */
      vpc_cidr                   = "10.26.128.0/21"
      vpc_private_subnets        = ["10.26.130.0/23", "10.26.132.0/23", "10.26.134.0/23"]
      vpc_public_subnets         = ["10.26.128.0/27", "10.26.128.32/27", "10.26.128.64/27"]
      vpc_database_subnets       = ["10.26.128.96/27", "10.26.128.128/27", "10.26.128.160/27"]
      vpc_enable_nat_gateway     = true
      vpc_one_nat_gateway_per_az = false

      /* EKS */
      eks_cluster_name = "apps-tools-${local.environment}"
      eks_versions = {
        cluster                   = "1.28"
        ami_release               = "1.16.0-d2d9cf87" // [major version].[minor version].[patch version]-[first 8 chars of commit SHA]. Get the SHA from here: https://github.com/bottlerocket-os/bottlerocket/releases
        addon_coredns             = "v1.10.1-eksbuild.5"
        addon_kube_proxy          = "v1.28.2-eksbuild.2"
        addon_vpc_cni             = "v1.15.3-eksbuild.1"
        addon_aws_guardduty_agent = "v1.3.1-eksbuild.1"
        addon_ebs_csi_driver      = "v1.24.1-eksbuild.1"
        addon_efs_csi_driver      = "v1.7.0-eksbuild.1"
      }
      eks_sso_access_role = "modernisation-platform-sandbox"

      /* Airflow */
      airflow_s3_bucket             = "moj-data-platform-airflow-development20230627094128036000000001" // This is defined in modernisation-platform-environments
      airflow_dag_s3_path           = "dags/"                                                           // This is defined in modernisation-platform-environments
      airflow_requirements_s3_path  = "requirements.txt"                                                // This is defined in modernisation-platform-environments
      airflow_execution_role_name   = "${local.application_name}-${local.environment}-airflow-execution"
      airflow_name                  = "${local.application_name}-${local.environment}"
      airflow_version               = "2.6.3"
      airflow_environment_class     = "mw1.medium"
      airflow_max_workers           = 2
      airflow_min_workers           = 1
      airflow_schedulers            = 2
      airflow_webserver_access_mode = "PUBLIC_ONLY"
      airflow_configuration_options = {
        "webserver.warn_deployment_exposure" = 0
      }
      airflow_mail_from_address               = "airflow"
      airflow_weekly_maintenance_window_start = "SAT:00:00"

      /* Open Metadata */
      openmetadata_role = "openmetadata"
      openmetadata_target_accounts = [
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["analytical-platform-data-production"]
      ]

      /* Observability Platform */
      observability_platform_account_id     = local.environment_management.account_ids["observability-platform-development"]
      observability_platform_role           = "data-platform-apps-and-tools-development-prometheus"
      observability_platform_prometheus_url = "https://aps-workspaces.eu-west-2.amazonaws.com/workspaces/ws-464eea97-631a-4e5d-af22-4c5528d9e0e6/api/v1/remote_write"

      /* Static Assets */
      static_assets_hostname = "assets.development.data-platform.service.justice.gov.uk"
    }
    production = {
      /* Route53 */
      route53_zone = "apps-tools.data-platform.service.justice.gov.uk" // This is defined in modernisation-platform-environments

      /* SES */
      ses_domain_identity = "apps-tools.data-platform.service.justice.gov.uk" // This is defined in modernisation-platform-environments

      /* VPC */
      vpc_cidr                   = "10.27.128.0/21"
      vpc_private_subnets        = ["10.27.130.0/23", "10.27.132.0/23", "10.27.134.0/23"]
      vpc_public_subnets         = ["10.27.128.0/27", "10.27.128.32/27", "10.27.128.64/27"]
      vpc_database_subnets       = ["10.27.128.96/27", "10.27.128.128/27", "10.27.128.160/27"]
      vpc_enable_nat_gateway     = true
      vpc_one_nat_gateway_per_az = false

      /* EKS */
      eks_cluster_name = "apps-tools-${local.environment}"
      eks_versions = {
        cluster                   = "1.28"
        ami_release               = "1.16.0-d2d9cf87" // [major version].[minor version].[patch version]-[first 8 chars of commit SHA]. Get the SHA from here: https://github.com/bottlerocket-os/bottlerocket/releases
        addon_coredns             = "v1.10.1-eksbuild.5"
        addon_kube_proxy          = "v1.28.2-eksbuild.2"
        addon_vpc_cni             = "v1.15.3-eksbuild.1"
        addon_aws_guardduty_agent = "v1.3.1-eksbuild.1"
        addon_ebs_csi_driver      = "v1.24.1-eksbuild.1"
        addon_efs_csi_driver      = "v1.7.0-eksbuild.1"
      }
      eks_sso_access_role = "modernisation-platform-developer"

      /* Airflow */
      airflow_s3_bucket             = "moj-data-platform-airflow-production20230908140747954800000002" // This is defined in modernisation-platform-environments
      airflow_dag_s3_path           = "dags/"                                                          // This is defined in modernisation-platform-environments
      airflow_requirements_s3_path  = "requirements.txt"                                               // This is defined in modernisation-platform-environments
      airflow_execution_role_name   = "${local.application_name}-${local.environment}-airflow-execution"
      airflow_name                  = "${local.application_name}-${local.environment}"
      airflow_version               = "2.6.3"
      airflow_environment_class     = "mw1.medium"
      airflow_max_workers           = 2
      airflow_min_workers           = 1
      airflow_schedulers            = 2
      airflow_webserver_access_mode = "PUBLIC_ONLY"
      airflow_configuration_options = {
        "webserver.warn_deployment_exposure" = 0
      }
      airflow_mail_from_address               = "airflow"
      airflow_weekly_maintenance_window_start = "SAT:00:00"

      /* Open Metadata */
      openmetadata_role = "openmetadata"
      openmetadata_target_accounts = [
        local.environment_management.account_ids["data-platform-production"],
        local.environment_management.account_ids["analytical-platform-data-production"]
      ]

      /* Observability Platform */
      observability_platform_account_id     = local.environment_management.account_ids["observability-platform-production"]
      observability_platform_role           = "data-platform-apps-and-tools-production-prometheus"
      observability_platform_prometheus_url = "https://aps-workspaces.eu-west-2.amazonaws.com/workspaces/ws-55a65e9b-aab9-47a0-88b4-8275c50f1ff9/api/v1/remote_write"

      /* Static Assets */
      static_assets_hostname = "assets.data-platform.service.justice.gov.uk"
    }
  }
}

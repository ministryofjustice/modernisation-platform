locals {
  environment_configuration = local.environment_configurations[local.environment]
  environment_configurations = {
    development = {
      apps_tools_eks_oidc_url                  = "https://oidc.eks.eu-west-2.amazonaws.com/id/BEE86BED6494692D4ED31C2ED2319E13"
      apps_tools_openmetadata_airflow_role_arn = "arn:aws:iam::335889174965:role/openmetadata-airflow20231002155028097300000001"
    }
    // production = {}
}
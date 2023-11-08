# Get the environments file from the main repository
data "http" "environments_file" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.application_name}.json"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}


##################################################
# Data Platform Apps and Tools Route 53
##################################################

data "aws_route53_zone" "apps_tools" {
  name         = local.environment_configuration.route53_zone
  private_zone = false
}

##################################################
# Data Platform Apps and Tools Airflow S3
##################################################

data "aws_s3_bucket" "airflow" {
  bucket = local.environment_configuration.airflow_s3_bucket
}

##################################################
# Data Platform Apps and Tools IAM
##################################################

data "aws_iam_roles" "eks_sso_access_role" {
  name_regex  = "AWSReservedSSO_${local.environment_configuration.eks_sso_access_role}_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

##################################################
# Data Platform Apps and Tools Open Metadata
##################################################

data "aws_secretsmanager_secret_version" "openmetadata_entra_id_client_id" {
  secret_id = "openmetadata/entra-id/client-id"
}

data "aws_secretsmanager_secret_version" "openmetadata_entra_id_tenant_id" {
  secret_id = "openmetadata/entra-id/tenant-id"
}

##################################################
# Data Platform Apps and Tools AuthO
##################################################

data "aws_secretsmanager_secret_version" "auth0_domain" {
  provider = aws.analytical-platform-management-production

  secret_id = "auth0/domain"
}

data "aws_secretsmanager_secret_version" "auth0_client_id" {
  provider = aws.analytical-platform-management-production

  secret_id = "auth0/client-id"
}

data "aws_secretsmanager_secret_version" "auth0_client_secret" {
  provider = aws.analytical-platform-management-production

  secret_id = "auth0/client-secret"
}

data "aws_cloudwatch_event_bus" "auth0" {
  name = "aws.partner/auth0.com/alpha-analytics-moj-c855a398-59a4-44d3-b042-7873e5a9ba75/auth0.logs" // This was created by Auth0, we accepted it in the UI
}

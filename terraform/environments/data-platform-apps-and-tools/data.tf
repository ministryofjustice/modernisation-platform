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



##################################################
# Data Platform Apps and Tools Open Metadata
##################################################

data "aws_secretsmanager_secret_version" "openmetadata_entra_id_client_id" {
  secret_id = "openmetadata/entra-id/client-id"
}

data "aws_secretsmanager_secret_version" "openmetadata_entra_id_tenant_id" {
  secret_id = "openmetadata/entra-id/tenant-id"
}

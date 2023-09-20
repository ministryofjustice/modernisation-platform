# Get the environments file from the main repository
data "http" "environments_file" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.application_name}.json"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

##################################################
# Data Platform Apps and Tools Airflow S3
##################################################

data "aws_s3_bucket" "airflow" {
  bucket = local.environment_configuration.airflow_s3_bucket
}

##################################################
# Data Platform Apps and Tools EKS
##################################################

data "aws_iam_roles" "eks_sso_access_role" {
  name_regex  = "AWSReservedSSO_${local.environment_configuration.eks_sso_access_role}_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

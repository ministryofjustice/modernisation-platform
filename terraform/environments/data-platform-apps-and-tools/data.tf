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
# Data Platform Apps and Tools EKS
##################################################
data "aws_ssm_parameter" "bottlerocket_image_id" {
  name = "/aws/service/bottlerocket/aws-k8s-${local.environment_configuration.eks_versions.cluster}/x86_64/latest/image_id"
}

data "aws_ami" "bottlerocket_image" {
  owners = ["amazon"]
  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.bottlerocket_image_id.value]
  }
}

data "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }
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

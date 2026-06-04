# Discover current region name - used when setting up vpc endpoints
data "aws_region" "current_region" {}

data "aws_kms_key" "general_shared" {
  key_id = "arn:aws:kms:eu-west-2:${local.environment_management.account_ids["core-shared-services-production"]}:alias/general-${lower(local.tags.business-unit)}"
}
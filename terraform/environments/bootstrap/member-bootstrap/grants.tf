module "grant-rhel-els" {
  source = "../../../modules/license-manager"
  providers = {
    aws.modernisation-platform-environment = aws.modernisation-platform-environments-us-east-1
    aws.modernisation-platform-account     = aws.modernisation-platform-us-east-1
  }
  account_to_grant       = local.environment_management.account_ids[terraform.workspace]
  destination_grant_name = "RHEL-6-ELS"
  source_license_sku     = "02e38931-bf68-46a4-925d-5fdf598c92d2"
}
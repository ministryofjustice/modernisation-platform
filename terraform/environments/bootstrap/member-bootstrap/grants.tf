module "grant-rhel-els" {
  source = "../../../modules/license-manager"
  providers = {
    aws.modernisation-platform-environment = aws
    aws.modernisation-platform-account     = aws.modernisation-platform
  }
  account_to_grant       = local.environment_management.account_ids[terraform.workspace]
  destination_grant_name = "RHEL-6-ELS"
  source_license_arn     = "arn:aws:license-manager::294406891311:license:l-d82b05a0dc724e79a1d164704144d38b"
}
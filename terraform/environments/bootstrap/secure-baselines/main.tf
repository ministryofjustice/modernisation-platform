module "baselines" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines?ref=v2.0.1"
  providers = {
    # Default and replication regions
    aws                    = aws.workspace-eu-west-2
    aws.replication-region = aws.workspace-eu-west-1

    # Enabled regions
    aws.eu-central-1 = aws.workspace-eu-central-1
    aws.eu-west-1    = aws.workspace-eu-west-1
    aws.eu-west-2    = aws.workspace-eu-west-2
    aws.us-east-1    = aws.workspace-us-east-1

    # We're part of a Organization SCP that restricts regional usage, so we can't assume roles in non-restricted regions.
    # However, Terraform doesn't support optional providers, so we have to ensure there is a provider
    # declaration for each region used in the module.
    #
    # Since we can't assume the roles, and Terraform doesn't support optional providers, we need to
    # "default" the regional providers for restricted regions to a region that is unrestricted.
    # They're not part of the enabled_baselines_region list, so Terraform won't try to
    # create any resources for these providers.
    aws.eu-north-1     = aws.workspace-eu-west-2
    aws.ap-northeast-1 = aws.workspace-eu-west-2
    aws.ap-northeast-2 = aws.workspace-eu-west-2
    aws.ap-south-1     = aws.workspace-eu-west-2
    aws.eu-west-3      = aws.workspace-eu-west-2
    aws.ap-southeast-1 = aws.workspace-eu-west-2
    aws.ap-southeast-2 = aws.workspace-eu-west-2
    aws.ca-central-1   = aws.workspace-eu-west-2
    aws.sa-east-1      = aws.workspace-eu-west-2
    aws.us-east-2      = aws.workspace-eu-west-2
    aws.us-west-1      = aws.workspace-eu-west-2
    aws.us-west-2      = aws.workspace-eu-west-2
  }

  # Regions to enable IAM Access Analyzer in
  enabled_access_analyzer_regions = local.enabled_baseline_regions

  # Regions to enable AWS Backup in
  enabled_backup_regions = local.enabled_baseline_regions

  # Regions to enable AWS Config in
  enabled_config_regions = local.enabled_baseline_regions

  # Regions to enable EBS encryption in
  enabled_ebs_encryption_regions = local.enabled_baseline_regions

  # Regions to enable GuardDuty in
  enabled_guardduty_regions = local.enabled_baseline_regions

  # Regions to enable Security Hub in
  enabled_securityhub_regions = local.enabled_baseline_regions

  # Regions to enable default VPC configuration and VPC Flow Logs in
  enabled_vpc_regions = local.enabled_baseline_regions

  root_account_id = local.root_account.master_account_id
  tags            = local.environments
}

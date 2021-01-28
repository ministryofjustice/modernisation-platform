module "baselines" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines?ref=v2.0.0"
  providers = {
    # Default and replication regions
    aws                    = aws.workspace-eu-west-2
    aws.replication-region = aws.workspace-eu-west-1

    # Other regions
    aws.ap-northeast-1 = aws.workspace-ap-northeast-1
    aws.ap-northeast-2 = aws.workspace-ap-northeast-2
    aws.ap-south-1     = aws.workspace-ap-south-1
    aws.ap-southeast-1 = aws.workspace-ap-southeast-1
    aws.ap-southeast-2 = aws.workspace-ap-southeast-2
    aws.ca-central-1   = aws.workspace-ca-central-1
    aws.eu-central-1   = aws.workspace-eu-central-1
    aws.eu-north-1     = aws.workspace-eu-north-1
    aws.eu-west-1      = aws.workspace-eu-west-1
    aws.eu-west-2      = aws.workspace-eu-west-2
    aws.eu-west-3      = aws.workspace-eu-west-3
    aws.sa-east-1      = aws.workspace-sa-east-1
    aws.us-east-1      = aws.workspace-us-east-1
    aws.us-east-2      = aws.workspace-us-east-2
    aws.us-west-1      = aws.workspace-us-west-1
    aws.us-west-2      = aws.workspace-us-west-2
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

# cloudtrail kms key lookup
data "aws_kms_key" "cloudtrail_key" {
  provider = aws.core-logging
  key_id   = "alias/s3-logging-cloudtrail"
}

# Regions to enable secure baselines in
locals {
  enabled_baseline_regions = [
    "eu-central-1", # Europe (Frankfurt)
    "eu-west-1",    # Europe (Ireland)
    "eu-west-2",    # Europe (London)
    "us-east-1",    # US East (N. Virginia) (for global services)
  ]
}

# Secure baselines (GuardDuty, Config, SecurityHub, etc)
module "baselines-modernisation-platform" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines?ref=v4.3.1"
  providers = {
    # Default and replication regions
    aws                    = aws.modernisation-platform-eu-west-2
    aws.replication-region = aws.modernisation-platform-eu-west-1

    # Other regions
    aws.ap-northeast-1 = aws.modernisation-platform-ap-northeast-1
    aws.ap-northeast-2 = aws.modernisation-platform-ap-northeast-2
    aws.ap-south-1     = aws.modernisation-platform-ap-south-1
    aws.ap-southeast-1 = aws.modernisation-platform-ap-southeast-1
    aws.ap-southeast-2 = aws.modernisation-platform-ap-southeast-2
    aws.ca-central-1   = aws.modernisation-platform-ca-central-1
    aws.eu-central-1   = aws.modernisation-platform-eu-central-1
    aws.eu-north-1     = aws.modernisation-platform-eu-north-1
    aws.eu-west-1      = aws.modernisation-platform-eu-west-1
    aws.eu-west-2      = aws.modernisation-platform-eu-west-2
    aws.eu-west-3      = aws.modernisation-platform-eu-west-3
    aws.sa-east-1      = aws.modernisation-platform-sa-east-1
    aws.us-east-1      = aws.modernisation-platform-us-east-1
    aws.us-east-2      = aws.modernisation-platform-us-east-2
    aws.us-west-1      = aws.modernisation-platform-us-west-1
    aws.us-west-2      = aws.modernisation-platform-us-west-2
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

  cloudtrail_kms_key = data.aws_kms_key.cloudtrail_key.arn

  root_account_id = local.root_account.master_account_id
  tags            = local.tags
}

# Trusted Advisor: refresh every 60 minutes
module "trusted-advisor-modernisation-platform" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-trusted-advisor?ref=v2.1.1"
}

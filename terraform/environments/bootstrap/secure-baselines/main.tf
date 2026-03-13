# cloudtrail kms key lookup
data "aws_kms_key" "cloudtrail_key" {
  provider = aws.core-logging
  key_id   = "alias/s3-logging-cloudtrail"
}

#trivy:ignore:AVD-AWS-0136
module "baselines" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines?ref=fbaa8e2989b3187348f0f9d626bdad9102e9e13f" # v9.1.2
  providers = {
    # Default and replication regions
    aws                    = aws.workspace-eu-west-2
    aws.replication-region = aws.workspace-eu-west-1

    # Enabled regions
    aws.eu-central-1 = aws.workspace-eu-central-1
    aws.eu-west-1    = aws.workspace-eu-west-1
    aws.eu-west-2    = aws.workspace-eu-west-2
    aws.eu-west-3    = aws.workspace-eu-west-3
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
    aws.ap-southeast-1 = aws.workspace-eu-west-2
    aws.ap-southeast-2 = aws.workspace-eu-west-2
    aws.ca-central-1   = aws.workspace-eu-west-2
    aws.sa-east-1      = aws.workspace-eu-west-2
    aws.us-east-2      = aws.workspace-eu-west-2
    aws.us-west-1      = aws.workspace-eu-west-2
    aws.us-west-2      = aws.workspace-eu-west-2
  }

  # Ensure bucket policy references correct account
  current_account_id = local.environment_management.account_ids[terraform.workspace]

  # Selectively reduce pre prod backups on certain accounts
  reduced_preprod_backup_retention = local.reduced_preprod_backup_retention

  # Selectively enable CloudTrail object-level logging
  enable_cloudtrail_s3_mgmt_events = local.enable-cloudtrail-events

  # Regions to enable IAM Access Analyzer in
  enabled_access_analyzer_regions = local.enabled_baseline_regions

  # Regions to enable AWS Backup in
  enabled_backup_regions = local.enabled_baseline_regions

  # Regions to enable AWS Config in
  enabled_config_regions = local.enabled_baseline_regions

  # Regions to enable EBS encryption in
  enabled_ebs_encryption_regions = local.enabled_baseline_regions

  # Regions to enable GuardDuty in
  # Guard duty is now enabled for all new accounts by default

  # Regions to enable Security Hub in
  enabled_securityhub_regions = local.enabled_baseline_regions

  cloudtrail_kms_key = data.aws_kms_key.cloudtrail_key.arn
  root_account_id    = local.root_account.master_account_id
  tags               = local.environments

  # Regions to enable IMDSv2 in
  enabled_imdsv2_regions = local.enabled_baseline_regions

  # Pass in pagerduty integration key for security hub alerts
  pagerduty_integration_key = local.pagerduty_integration_keys["security_hub_members"]

  # PagerDuty Key for High Priority Alarms
  high_priority_pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_high_priority_cloudwatch"]

  # Individual Slack Alerts for CRITICAL and other severity SecurityHub alerts if the account is in scope and the criticality is set.
  enable_securityhub_slack_alerts                    = local.securityhub_slack_alerts_accounts
  securityhub_slack_alerts_scope                     = local.securityhub_slack_alerts_scope
  securityhub_slack_alerts_pagerduty_integration_key = local.pagerduty_integration_keys["security_hub_alerts_critical_priority"]
  enable_securityhub_event_forwarding                = local.enable_securityhub_event_forwarding
  securityhub_central_event_bus_arn                  = local.securityhub_central_event_bus_arn

}

# Keys for pagerduty
data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  provider  = aws.modernisation-secrets-read
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
}

# Get the map of pagerduty integration keys
data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  provider = aws.modernisation-secrets-read
  name     = "pagerduty_integration_keys"
}

# Keys for pagerduty
locals {
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)
}

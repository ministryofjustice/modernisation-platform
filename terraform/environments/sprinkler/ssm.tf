module "ssm-auto-patching" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-ssm-patching.git?ref=1eeb6997e025581625554e9f291ed9d927e097ad"
  count  = local.environment == "development" ? 1 : 0
  providers = {
    aws.bucket-replication = aws
  }


  account_number             = local.environment_management.account_ids[terraform.workspace]
  application_name           = local.application_name
  vpc_all                    = "garden-sandbox"
  patch_schedule             = "cron(30 17 ? * MON *)"
  tags = merge(
    local.tags,
    {
      Name = "ssm-patching"
    },
  )
}
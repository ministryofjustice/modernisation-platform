module "ssm-auto-patching" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-ssm-patching.git?ref=4f0d509774fe46f3a88c68141e3674bf16db203d"
  count  = local.environment == "development" ? 1 : 0
  providers = {
    aws.bucket-replication = aws
  }

  account_number             = local.environment_management.account_ids[terraform.workspace]
  application_name           = local.application_name
  vpc_all                    = "garden-sandbox"
  patch_schedule             = "cron(14 15 ? * THUR *)"
  tags = merge(
    local.tags,
    {
      Name = "ssm-patching"
    },
  )
}
resource "aws_backup_plan" "cloudtrail_s3_extended_window" {
  name = "cloudtrail-s3-extended-window"

  rule {
    rule_name         = "backup-daily-retain-30-days-cloudtrail-s3"
    target_vault_name = "everything"

    # Backup every day at 00:30am
    schedule = "cron(30 0 * * ? *)"

    # Keep the same 1-hour start window but allow up to 180 hours to complete
    # the initial full scan for this very large bucket.
    start_window      = 60
    completion_window = 10800

    lifecycle {
      delete_after = 30
    }
  }

  tags = local.tags
}

resource "aws_backup_selection" "cloudtrail_s3_extended_window" {
  name         = "cloudtrail-s3-extended-window"
  iam_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSBackup"
  plan_id      = aws_backup_plan.cloudtrail_s3_extended_window.id
  resources    = [module.s3-bucket-cloudtrail.bucket.arn]
}

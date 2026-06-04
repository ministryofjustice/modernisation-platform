resource "aws_kms_key" "pagerduty" {
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.pagerduty_kms.json
  tags                = local.tags
}

resource "aws_kms_alias" "pagerduty" {
  name          = "alias/pagerduty-secret"
  target_key_id = aws_kms_key.pagerduty.id
}

resource "aws_kms_key" "pagerduty_multi_region" {
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.pagerduty_kms.json
  multi_region        = true
  tags                = local.tags
}

resource "aws_kms_alias" "pagerduty_multi_region" {
  name          = "alias/pagerduty-secret-multi-region"
  target_key_id = aws_kms_key.pagerduty_multi_region.id
}

resource "aws_kms_replica_key" "pagerduty_multi_region_replica" {
  description             = "AWS Secretsmanager CMK replica key"
  deletion_window_in_days = 30
  primary_key_arn         = aws_kms_key.pagerduty_multi_region.arn
  provider                = aws.modernisation-platform-eu-west-1
}

resource "aws_kms_alias" "pagerduty_multi_region_replica" {
  name          = "alias/pagerduty-secret-multi-region-replica"
  target_key_id = aws_kms_replica_key.pagerduty_multi_region_replica.id
}
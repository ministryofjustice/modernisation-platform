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
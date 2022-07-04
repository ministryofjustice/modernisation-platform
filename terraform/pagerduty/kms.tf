resource "aws_kms_key" "pagerduty" {
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_kms_alias" "pagerduty" {
  name          = "alias/pagerduty-secret"
  target_key_id = aws_kms_key.pagerduty.id
}
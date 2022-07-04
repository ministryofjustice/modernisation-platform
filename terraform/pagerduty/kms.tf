resource "aws_kms_key" "pagerduty" {
  tags = local.tags
}

resource "aws_kms_alias" "pagerduty" {
  target_key_id = aws_kms_key.pagerduty.id
}
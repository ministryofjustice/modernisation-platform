resource "aws_ssm_parameter" "cortex_account_id" {
  #checkov:skip=CKV2_AWS_34: "Parameter is not sensitive; account ID is publicly available."
  lifecycle {
    ignore_changes = [value]
  }
  provider    = aws.modernisation-platform
  description = "Account ID for Palo Alto XSIAM Cortex cross-account role."
  name        = "cortex_account_id"
  type        = "String"
  value       = ""
  tags        = local.tags
}
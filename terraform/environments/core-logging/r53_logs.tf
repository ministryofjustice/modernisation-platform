resource "aws_route53_resolver_query_log_config" "s3" {
  name            = format("%s-rlq-s3", local.application_name)
  destination_arn = aws_s3_bucket.logging["r53-resolver-logs"].arn
  tags            = local.tags
}

resource "aws_route53_resolver_query_log_config" "cloudwatch" {
  name            = format("%s-rlq-cloudwatch", local.application_name)
  destination_arn = aws_cloudwatch_log_group.r53_resolver_logs.arn
  tags            = local.tags
}

#Temporarily unencrypted while I consider a suitable KMS policy
resource "aws_cloudwatch_log_group" "r53_resolver_logs" {
  name_prefix       = "r53-resolver-logs"
  retention_in_days = 365
  tags              = local.tags
}

locals {
  resolver_query_log_configs = {
    s3         = aws_route53_resolver_query_log_config.s3.arn
    cloudwatch = aws_route53_resolver_query_log_config.cloudwatch.arn
  }
}

resource "aws_ram_resource_share" "resolver_query_share" {
  allow_external_principals = false
  name                      = format("%s-resolver-log-query-share", local.application_name)
  tags                      = local.tags
}

resource "aws_ram_resource_association" "resolver_query_share" {
  for_each           = local.resolver_query_log_configs
  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.resolver_query_share.id
}

resource "aws_ram_principal_association" "resolver_query_share" {
  principal          = "${data.aws_organizations_organization.root_account.arn}/${local.environment_management.modernisation_platform_organisation_unit_id}"
  resource_share_arn = aws_ram_resource_share.resolver_query_share.arn
}


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
  principal          = replace("${data.aws_organizations_organization.root_account.arn}/${local.environment_management.modernisation_platform_organisation_unit_id}", "organization/", "ou/")
  resource_share_arn = aws_ram_resource_share.resolver_query_share.arn
}

resource "aws_ram_resource_share" "resolver_query_share_eu_west_1" {
  provider                  = aws.modernisation-platform-eu-west-1
  allow_external_principals = false
  name                      = format("%s-resolver-log-query-share", local.application_name)
  tags                      = local.tags
}

resource "aws_ram_resource_association" "resolver_query_share_eu_west_1" {
  provider           = aws.modernisation-platform-eu-west-1
  resource_arn       = aws_route53_resolver_query_log_config.s3_eu_west_1.arn
  resource_share_arn = aws_ram_resource_share.resolver_query_share_eu_west_1.id
}

resource "aws_ram_principal_association" "resolver_query_share_eu_west_1" {
  provider           = aws.modernisation-platform-eu-west-1
  principal          = replace("${data.aws_organizations_organization.root_account.arn}/${local.environment_management.modernisation_platform_organisation_unit_id}", "organization/", "ou/")
  resource_share_arn = aws_ram_resource_share.resolver_query_share_eu_west_1.arn
}



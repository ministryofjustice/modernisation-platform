locals {
  resolver_query_log_configs = {
    s3         = aws_route53_resolver_query_log_config.s3.arn
    cloudwatch = aws_route53_resolver_query_log_config.cloudwatch.arn
  }
}

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

resource "aws_cloudwatch_log_group" "r53_resolver_logs" {
  kms_key_id        = aws_kms_key.r53_resolver_logs.id
  name_prefix       = "r53-resolver-logs"
  retention_in_days = 365
  tags              = local.tags
}

resource "aws_kms_key" "r53_resolver_logs" {
  description         = "KMS key used to encrypt R53 Resolver Logs CloudWatch log group"
  enable_key_rotation = true
  multi_region        = true
  policy              = data.aws_iam_policy_document.r53_resolver_logs_kms.json
  tags                = local.tags
}

data "aws_iam_policy_document" "r53_resolver_logs_kms" {
  statement {
    sid    = "Allow management access of the key to the logging account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid    = "Allow AWS Log service to use key"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "Service"
      identifiers = [
        "logs.amazonaws.com"
      ]
    }
  }
}

locals {
  resolver_query_log_config_names = toset(["core-logging-rlq-cloudwatch", "core-logging-rlq-s3"])
  vpc_ids                         = { for key, value in module.vpc_inspection : key => value["vpc_id"] if key == "live_data" }
  rlq_ids                         = { for name, config in data.aws_route53_resolver_query_log_config.core_logging : name => config.id }
  vpc_rlq_associations = merge([
    for vpc_key, vpc_id in local.vpc_ids : {
      for rlq_name, rlq_id in local.rlq_ids :
      "${vpc_key}_${rlq_name}" => {
        vpc_id = vpc_id
        rlq_id = rlq_id
      }
    }
  ]...)
}

data "aws_route53_resolver_query_log_config" "core_logging" {
  for_each = local.resolver_query_log_config_names
  filter {
    name   = "Name"
    values = [each.value]
  }
}

resource "aws_route53_resolver_query_log_config_association" "core_logging" {
  for_each                     = local.is-production ? local.vpc_rlq_associations : {}
  resolver_query_log_config_id = each.value.rlq_id
  resource_id                  = each.value.vpc_id
}

module "stream_firewall_logs" {
  source                     = "github.com/ministryofjustice/modernisation-platform-terraform-aws-data-firehose?ref=c350bc56f980cddededac981d1bfc8479da715e9" # v3.0.0
  cloudwatch_log_group_names = [module.vpc_inspection["live_data"].fw_cloudwatch_name, module.firewall_logging.cloudwatch_log_group_name]
  destination_http_endpoint  = data.aws_ssm_parameter.cortex_xsiam_endpoint.value
  tags                       = local.tags
}


# Public DNS Query Logging
resource "aws_cloudwatch_log_group" "public_dns_query_logging" {
  provider          = aws.aws-us-east-1
  name              = "/aws/route53/resolver/core-public-dns-query-logging"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.public_dns_query_logging.arn
  tags              = local.tags
  depends_on        = [aws_kms_key.public_dns_query_logging]
}

resource "aws_cloudwatch_log_resource_policy" "public_dns_query_logging" {
  provider    = aws.aws-us-east-1
  policy_name = "core-public-dns-query-logging"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRoute53ToPutLogs"
        Effect = "Allow"
        Principal = {
          Service = "route53.amazonaws.com"
        }
        Action = ["logs:CreateLogStream", "logs:DescribeLogStreams", "logs:PutLogEvents"]
        Resource = [
          aws_cloudwatch_log_group.public_dns_query_logging.arn,
          "${aws_cloudwatch_log_group.public_dns_query_logging.arn}:*"
        ]
      }
    ]
  })
}

resource "aws_route53_query_log" "public_dns_query_logging" {
  provider                 = aws.aws-us-east-1
  for_each                 = aws_route53_zone.application_zones
  zone_id                  = each.value.zone_id
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.public_dns_query_logging.arn
  depends_on               = [aws_cloudwatch_log_resource_policy.public_dns_query_logging]
}

resource "aws_kms_key" "public_dns_query_logging" {
  provider                = aws.aws-us-east-1
  description             = "KMS key for encrypting public DNS query logging CloudWatch log group"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = local.tags
}

resource "aws_kms_alias" "public_dns_query_logging" {
  provider      = aws.aws-us-east-1
  name          = "alias/public-dns-query-logging"
  target_key_id = aws_kms_key.public_dns_query_logging.id
}

resource "aws_kms_key_policy" "public_dns_query_logging" {
  provider = aws.aws-us-east-1
  key_id   = aws_kms_key.public_dns_query_logging.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow administration of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs to use the key"
        Effect = "Allow"
        Principal = {
          Service = "logs.us-east-1.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:us-east-1:${local.environment_management.account_ids["core-network-services-production"]}:log-group:${aws_cloudwatch_log_group.public_dns_query_logging.name}"
          }
        }
      }
    ]
  })
}
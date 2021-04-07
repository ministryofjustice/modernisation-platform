
provider "aws" {
  alias = "core-network-services" # Provider that holds the resource share
}

locals {
  modernisation-platform-domain          = "modernisation-platform.service.justice.gov.uk"
  modernisation-platform-internal-domain = "modernisation-platform.internal"

  account_names  = [for key, account in var.accounts : account]
  environment_id = { for key, env in var.environments : key => env }

  account_numbers = flatten([
    for value in flatten(local.account_names) :
    local.environment_id.account_ids[value]
  ])

}

resource "aws_route53_zone" "public" {

  name = "${var.dns_zone}.${local.modernisation-platform-domain}"

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-public-zone"
    },
  )
}

//create private route53 zone
resource "aws_route53_zone" "private" {

  name = "${var.dns_zone}.${local.modernisation-platform-internal-domain}"

  vpc {
    vpc_id = var.vpc_id
  }

  lifecycle {
    ignore_changes = [vpc]
  }

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-internal-zone"
    },
  )
}

//Adds DNS name records to the public zone
resource "aws_route53_record" "mod-ns-public" {
  provider = aws.core-network-services
  zone_id  = var.public_dns_zone.id
  name     = "${var.dns_zone}.${local.modernisation-platform-domain}"
  type     = "NS"
  ttl      = "30"
  records  = aws_route53_zone.public.name_servers
}

//Adds DNS name records to the private zone
resource "aws_route53_record" "mod-ns-private" {
  provider = aws.core-network-services
  zone_id  = var.private_dns_zone.id
  name     = "${var.dns_zone}.${local.modernisation-platform-internal-domain}"
  type     = "NS"
  ttl      = "30"
  records  = aws_route53_zone.private.name_servers
}

# IAM Section ----------------

# DNS IAM
resource "aws_iam_role" "dns" {
  name = "dns-${var.dns_zone}"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : local.account_numbers
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {}
        }
      ]
  })

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-dns-role"
    },
  )
}

resource "aws_iam_role_policy" "dns" {
  name = "dns-${var.dns_zone}"
  role = aws_iam_role.dns.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListReusableDelegationSets",
          "route53:ListTrafficPolicyInstances",
          "route53:GetTrafficPolicyInstanceCount",
          "route53:CreateTrafficPolicy",
          "route53:TestDNSAnswer",
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName",
          "route53:GetAccountLimit",
          "route53:GetCheckerIpRanges",
          "route53:ListHealthChecks",
          "route53:CreateHealthCheck",
          "route53:ListTrafficPolicies",
          "route53:GetGeoLocation",
          "route53:ListGeoLocations",
          "route53:GetHostedZoneCount",
          "route53:GetHealthCheckCount"
        ],
        "Resource" : "*"
      },
      {
        Action = ["route53:ChangeResourceRecordSets"]
        Effect = "Allow"
        Resource = [
          "arn:aws:route53:::hostedzone/${aws_route53_zone.public.id}",
          "arn:aws:route53:::hostedzone/${aws_route53_zone.private.id}"
        ]
      },
    ]
  })
}

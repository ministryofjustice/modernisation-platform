
provider "aws" {
  alias = "core-network-services" # Provider that holds the resource share
}

locals {
  modernisation-platform-domain          = "modernisation-platform.service.justice.gov.uk"
  modernisation-platform-internal-domain = "modernisation-platform.internal"

  account_names  = [for key, account in var.accounts : account]
  environment_id = { for key, env in var.environments : key => env }

  account_numbers = concat(flatten([
    for value in flatten(local.account_names) :
    local.environment_id.account_ids[value]
    ]),
    [var.modernisation_platform_account]
  )

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

output "zone_public" {
  value = aws_route53_zone.public.id
}
output "zone_private" {
  value = aws_route53_zone.private.id
}
provider "aws" {
  alias = "core-network-services" # Provider that holds the resource share
}

data "aws_route53_zone" "public" {
  provider = aws.core-network-services
  name         = local.modernisation-platform-domain
  private_zone = false
}

data "aws_route53_zone" "private" {
  provider = aws.core-network-services
  name         = local.modernisation-platform-internal-domain
  private_zone = true
}


locals {
  modernisation-platform-domain = "modernisation-platform.service.justice.gov.uk"
  modernisation-platform-internal-domain = "modernisation-platform.internal"
}


resource "aws_route53_zone" "public" {
  
  name = "${var.dns_zone}.${local.modernisation-platform-domain}"

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_zone" "private" {
  
  name = "${var.dns_zone}.internal"

}

//Adds DNS name records to the public zone
resource "aws_route53_record" "mod-ns-public" {
  provider = aws.core-network-services
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.dns_zone}.${local.modernisation-platform-domain}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.public.name_servers
}

//Adds DNS name records to the private zone
resource "aws_route53_record" "mod-ns-private" {
  provider = aws.core-network-services
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "${var.dns_zone}.${local.modernisation-platform-internal-domain}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.private.name_servers
}

# output "test_public" {
  
#   value = data.aws_route53_zone.public
# }
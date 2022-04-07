locals {
  modernisation-platform-domain          = "modernisation-platform.service.justice.gov.uk"
  modernisation-platform-internal-domain = "modernisation-platform.internal"

  application-zones = {
    equip = "equip.service.justice.gov.uk"
  }
}

# Main Modernisation Platform zones
resource "aws_route53_zone" "modernisation-platform" {
  name = local.modernisation-platform-domain
  tags = local.tags
}

resource "aws_route53_zone" "modernisation-platform-internal" {

  name = local.modernisation-platform-internal-domain

  vpc {
    vpc_id = module.vpc_hub["live_data"].vpc_id
  }

  tags = local.tags
}

# Application hosted zones
resource "aws_route53_zone" "application_zones" {
  for_each = local.application-zones

  name = each.value

  tags = merge(
    local.tags,
    {
      Name = "${each.key}-hosted-zone"
    }
  )
}

# Remote Supervision NS delegation
resource "aws_route53_record" "remote-supervision-production" {
  allow_overwrite = true
  name            = "rs-production.${local.modernisation-platform-domain}"
  ttl             = 30
  type            = "NS"
  zone_id         = aws_route53_zone.modernisation-platform.zone_id
  records = [
    "ns-1009.awsdns-62.net.",
    "ns-1104.awsdns-10.org.",
    "ns-316.awsdns-39.com.",
    "ns-1876.awsdns-42.co.uk"
  ]
}

resource "aws_route53_record" "remote-supervision-non-production" {
  allow_overwrite = true
  name            = "rs-non-production.${local.modernisation-platform-domain}"
  ttl             = 30
  type            = "NS"
  zone_id         = aws_route53_zone.modernisation-platform.zone_id
  records = [
    "ns-897.awsdns-48.net.",
    "ns-1217.awsdns-24.org.",
    "ns-77.awsdns-09.com.",
    "ns-1636.awsdns-12.co.uk."
  ]
}

# Bichard7 NS delegation
resource "aws_route53_record" "bichard7" {
  allow_overwrite = true
  name            = "bichard7.${local.modernisation-platform-domain}"
  ttl             = 30
  type            = "NS"
  zone_id         = aws_route53_zone.modernisation-platform.zone_id
  records = [
    "ns-1067.awsdns-05.org.",
    "ns-434.awsdns-54.com.",
    "ns-1782.awsdns-30.co.uk.",
    "ns-836.awsdns-40.net."
  ]
}

# Github pages user guidance CNAME record

resource "aws_route53_record" "github_pages" {
  zone_id = aws_route53_zone.modernisation-platform.zone_id
  name    = "user-guide"
  type    = "CNAME"
  ttl     = "30"
  records = ["ministryofjustice.github.io"]
}

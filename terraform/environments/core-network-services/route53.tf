locals {
  modernisation-platform-domain = "modernisation-platform.service.justice.gov.uk"
}

resource "aws_route53_zone" "modernisation-platform" {
  name = local.modernisation-platform-domain
  tags = local.tags
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

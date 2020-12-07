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
    "ns-1127.awsdns-12.org.",
    "ns-123.awsdns-15.com.",
    "ns-643.awsdns-16.net.",
    "ns-1848.awsdns-39.co.uk."
  ]
}

resource "aws_route53_record" "remote-supervision-non-production" {
  allow_overwrite = true
  name            = "rs-non-production.${local.modernisation-platform-domain}"
  ttl             = 30
  type            = "NS"
  zone_id         = aws_route53_zone.modernisation-platform.zone_id
  records = [
    "ns-1127.awsdns-12.org.",
    "ns-123.awsdns-15.com.",
    "ns-643.awsdns-16.net.",
    "ns-1848.awsdns-39.co.uk."
  ]
}

locals {
  modernisation-platform-domain          = "modernisation-platform.service.justice.gov.uk"
  modernisation-platform-internal-domain = "modernisation-platform.internal"

  application-zones = {
    ccms-ebs      = "ccms-ebs.service.justice.gov.uk",
    cdpt-chaps    = "correspondence-handling-and-processing.service.justice.gov.uk",
    cdpt-ifs      = "integratedfraudsystem.justice.gov.uk",
    dacp          = "divorce-section-search.service.justice.gov.uk",
    delius-jitbit = "jitbit.cr.probation.service.justice.gov.uk",
    equip         = "equip.service.justice.gov.uk",
    mlra          = "maat-libra-administration-tool.service.justice.gov.uk",
    mojfin        = "laa-finance-data.service.justice.gov.uk",
    ncas          = "neutral-citation-allocation.service.justice.gov.uk",
    pra-register  = "parental-responsibility-agreement.service.justice.gov.uk",
    tipstaff      = "tipstaff.service.justice.gov.uk",
    wardship      = "wardship-agreements-register.service.justice.gov.uk"
  }

  private-application-zones = {
  }
}

resource "aws_route53_zone" "private_application_zones" {

  for_each = local.private-application-zones
  name     = each.value

  vpc {
    vpc_id = module.vpc_inspection["live_data"].vpc_id
  }

  lifecycle {
    ignore_changes = [vpc]
  }
  tags = local.tags
}

# Main Modernisation Platform zones
resource "aws_route53_zone" "modernisation-platform" {
  name = local.modernisation-platform-domain
  tags = local.tags
}

resource "aws_route53_zone" "modernisation-platform-internal" {

  name = local.modernisation-platform-internal-domain

  vpc {
    vpc_id = module.vpc_inspection["live_data"].vpc_id
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

# Shield advanced protection
resource "aws_shield_protection" "modernisation_platform_public_hosted_zone" {
  name         = "modernisation-platform-public-hosted-zone"
  resource_arn = aws_route53_zone.modernisation-platform.arn

  tags = local.tags
}

resource "aws_shield_protection" "application_public_hosted_zone" {
  for_each = aws_route53_zone.application_zones

  name         = each.value.tags.Name
  resource_arn = each.value.arn

  tags = local.tags
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
  ttl     = "300"
  records = ["ministryofjustice.github.io"]
}

resource "aws_route53_record" "pagerduty_mail_cname" {
  zone_id = aws_route53_zone.modernisation-platform.zone_id
  name    = "em3857.status"
  type    = "CNAME"
  ttl     = "300"
  records = ["u31181182.wl183.sendgrid.net"]
}
resource "aws_route53_record" "pagerduty_dkim1" {
  zone_id = aws_route53_zone.modernisation-platform.zone_id
  name    = "pdt._domainkey.status"
  type    = "CNAME"
  ttl     = "300"
  records = ["pdt.domainkey.u31181182.wl183.sendgrid.net"]
}
resource "aws_route53_record" "pagerduty_dkim2" {
  zone_id = aws_route53_zone.modernisation-platform.zone_id
  name    = "pdt2._domainkey.status"
  type    = "CNAME"
  ttl     = "300"
  records = ["pdt2.domainkey.u31181182.wl183.sendgrid.net"]
}
resource "aws_route53_record" "pagerduty_http" {
  zone_id = aws_route53_zone.modernisation-platform.zone_id
  name    = "status"
  type    = "CNAME"
  ttl     = "300"
  records = ["cd-2b4752bd7016497638e8dfd051a53722.hosted-status.pagerduty.com"]
}

resource "aws_route53_record" "pagerduty_tls-certificate" {
  zone_id = aws_route53_zone.modernisation-platform.zone_id
  name    = "_0b49b12fdddbd40651a7458e0b054120.status"
  type    = "CNAME"
  ttl     = "300"
  records = ["_2b9d3139a782805455e260f16df743e1.xpybkgmvdt.acm-validations.aws."]
}
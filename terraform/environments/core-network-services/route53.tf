locals {
  modernisation-platform-domain          = "modernisation-platform.service.justice.gov.uk"
  modernisation-platform-internal-domain = "modernisation-platform.internal"

  application-zones = {
    ccms-ebs      = "ccms-ebs.service.justice.gov.uk",
    cdpt-chaps    = "correspondence-handling-and-processing.service.justice.gov.uk",
    cdpt-ifs      = "integrated-fraud-system.service.justice.gov.uk",
    dacp          = "divorce-section-search.service.justice.gov.uk",
    delius-jitbit = "jitbit.cr.probation.service.justice.gov.uk",
    equip         = "equip.service.justice.gov.uk",
    laa-apex      = "laa-apex.service.justice.gov.uk",
    maat          = "means-assessment-administration.service.justice.gov.uk",
    mlra          = "maat-libra-administration-tool.service.justice.gov.uk",
    mojfin        = "laa-finance-data.service.justice.gov.uk",
    ncas          = "neutral-citation-allocation.service.justice.gov.uk",
    ppud          = "ppud.justice.gov.uk",
    pra-register  = "parental-responsibility-agreement.service.justice.gov.uk",
    tipstaff      = "tipstaff.service.justice.gov.uk",
    tribunals     = "tribunals.gov.uk",
    wardship      = "wardship-agreements-register.service.justice.gov.uk"
    legalservices = "legalservices.gov.uk"
    laa           = "laa.service.justice.gov.uk"
  }

  private-application-zones = {
    aws-prd-legalservices-gov-uk = "aws.prd.legalservices.gov.uk"
    yjaf-development             = "development.yjaf"
    yjaf-test                    = "test.yjaf",
    yjaf-preproduction           = "preproduction.yjaf",
    yjaf-production              = "production.yjaf"
  }

  legalservices_records = {
    "legalservices"             = { name = "legalservices.gov.uk", type = "A", ttl = 300, records = ["151.101.2.30"] }
    "wwwlegalservices"          = { name = "www.legalservices.gov.uk", type = "A", ttl = 300, records = ["151.101.2.30"] }
    "mxlegalservices"           = { name = "legalservices.gov.uk", type = "MX", ttl = 300, records = ["0 legalservices-gov-uk.mail.protection.outlook.com"] }
    "securetransfer"            = { name = "securetransfer.legalservices.gov.uk", type = "A", ttl = 300, records = ["34.240.69.223"] }
    "gwasecuretransfer"         = { name = "gwa.securetransfer.legalservices.gov.uk", type = "A", ttl = 300, records = ["34.240.69.223"] }
    "hybridtoolssecuretransfer" = { name = "hybridtools.securetransfer.legalservices.gov.uk", type = "A", ttl = 300, records = ["34.240.69.223"] }
    "managersecuretransfer"     = { name = "manager.securetransfer.legalservices.gov.uk", type = "A", ttl = 300, records = ["34.240.69.223"] }
    "oosecuretransfer"          = { name = "oo.securetransfer.legalservices.gov.uk", type = "A", ttl = 300, records = ["34.240.69.223"] }
    "gwphybrid"                 = { name = "gwphybrid.securetransfer.legalservices.gov.uk", type = "A", ttl = 300, records = ["34.240.69.223"] }
    "dev"                       = { name = "dev.legalservices.gov.uk", type = "NS", ttl = 300, records = ["ns-674.awsdns-20.net", "ns-1463.awsdns-54.org", "ns-1537.awsdns-00.co.uk", "ns-495.awsdns-61.com"] }
    "tst"                       = { name = "tst.legalservices.gov.uk", type = "NS", ttl = 300, records = ["ns-1914.awsdns-47.co.uk", "ns-609.awsdns-12.net", "ns-195.awsdns-24.com", "ns-1187.awsdns-20.org"] }
    "uat"                       = { name = "uat.legalservices.gov.uk", type = "NS", ttl = 300, records = ["ns-938.awsdns-53.net", "ns-1046.awsdns-02.org", "ns-334.awsdns-41.com", "ns-1731.awsdns-24.co.uk"] }
    "stg"                       = { name = "stg.legalservices.gov.uk", type = "NS", ttl = 300, records = ["ns-1269.awsdns-30.org", "ns-1897.awsdns-45.co.uk", "ns-296.awsdns-37.com", "ns-917.awsdns-50.net"] }
    "ses-1"                     = { name = "u2hsqlvidbbhlfkkiff3fpuwjm6gu5mq._domainkey.legalservices.gov.uk", type = "CNAME", ttl = 300, records = ["u2hsqlvidbbhlfkkiff3fpuwjm6gu5mq.dkim.amazonses.com"] }
    "ses-2"                     = { name = "3jn7gxoog7vhao6dnt4vytejnkwrxaow._domainkey.legalservices.gov.uk", type = "CNAME", ttl = 300, records = ["3jn7gxoog7vhao6dnt4vytejnkwrxaow.dkim.amazonses.com"] }
    "ses-3"                     = { name = "lr4yk5yyneh2seaoiujphvk23mow7vty._domainkey.legalservices.gov.uk", type = "CNAME", ttl = 300, records = ["lr4yk5yyneh2seaoiujphvk23mow7vty.dkim.amazonses.com"] }
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

# Legalservices records
resource "aws_route53_record" "legalservices" {
  #checkov:skip=CKV2_AWS_23:"Route53 A Record has Attached Resource"
  for_each = local.legalservices_records
  zone_id  = aws_route53_zone.application_zones["legalservices"].zone_id
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.ttl
  records  = each.value.records
}

resource "aws_route53_record" "portal" {
  # checkov:skip=CKV2_AWS_23: "Route53 A Record has Attached Resource"
  zone_id = aws_route53_zone.application_zones["legalservices"].zone_id
  name    = "portal.legalservices.gov.uk"
  type    = "A"

  alias {
    name                   = "d1yzmx9d5z0sdz.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

# aws.prd.legalservices.gov.uk records
resource "aws_route53_record" "cwa-prod-db" {
  # checkov:skip=CKV2_AWS_23: "Route53 A Record has Attached Resource"
  zone_id = aws_route53_zone.private_application_zones["aws-prd-legalservices-gov-uk"].zone_id
  name    = "cwa-prod-db"
  type    = "A"

  alias {
    name                   = "cwa-production-db-nlb-blue-green-6a4d60ef7d3e7b0b.elb.eu-west-2.amazonaws.com"
    zone_id                = "ZD4D7Y8KGAS4G"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cwa-prod-db1" {
  # checkov:skip=CKV2_AWS_23: "Route53 A Record has Attached Resource"
  zone_id = aws_route53_zone.private_application_zones["aws-prd-legalservices-gov-uk"].zone_id
  name    = "cwa-prod-db1"
  type    = "A"

  alias {
    name                   = "cwa-production-database-nlb-12d44851fda0f196.elb.eu-west-2.amazonaws.com"
    zone_id                = "ZD4D7Y8KGAS4G"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cwa-prod-db3" {
  # checkov:skip=CKV2_AWS_23: "Route53 A Record has Attached Resource"
  zone_id = aws_route53_zone.private_application_zones["aws-prd-legalservices-gov-uk"].zone_id
  name    = "cwa-prod-db3"
  type    = "A"

  alias {
    name                   = "cwa-production-db-nlb-green-68322e6a90023a4a.elb.eu-west-2.amazonaws.com"
    zone_id                = "ZD4D7Y8KGAS4G"
    evaluate_target_health = false
  }
} 
resource "aws_route53_zone" "aws_uat_legalservices_gov_uk" {
  count = terraform.workspace == "core-vpc-development" ? 1 : 0
  name = "aws.uat.legalservices.gov.uk"

  vpc {
    vpc_id = module.vpc["laa-${local.environment}"].vpc_id
  }
  tags = local.tags
}

resource "aws_route53_record" "portal_oid" {
  count = terraform.workspace == "core-vpc-development" ? 1 : 0
  name    = "portal-oid.aws.uat.legalservices.gov.uk"
  records = ["10.206.4.156", "10.206.6.93"]
  type    = "A"
  ttl     = 300
  zone_id = aws_route53_zone.aws_uat_legalservices_gov_uk[0].zone_id
}

data "aws_route53_zone" "private" {
  for_each     = var.zone_id
  name         = "${each.value}-${var.environment}${var.dns_domain}"
  private_zone = true
}

resource "aws_route53_zone_association" "extend" {

  for_each = data.aws_route53_zone.private
  zone_id  = each.value.id
  vpc_id   = var.vpc_id
}

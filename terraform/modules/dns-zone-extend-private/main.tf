data "aws_route53_zone" "private" {
  provider     = aws.core-network-services
  for_each     = var.zone_name
  name         = each.value
  private_zone = true
}

resource "aws_route53_vpc_association_authorization" "private_zone_vpc_auth" {
  provider = aws.core-network-services
  for_each = data.aws_route53_zone.private
  vpc_id   = var.vpc_id
  zone_id  = each.value.zone_id
}

resource "aws_route53_zone_association" "private_zone_assoc" {
  for_each = data.aws_route53_zone.private
  vpc_id   = var.vpc_id
  zone_id  = each.value.zone_id
}
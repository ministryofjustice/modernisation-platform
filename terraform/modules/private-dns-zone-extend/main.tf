data "aws_route53_zone" "private" {
 provider = aws.core-network-services
 name = var.business_unit_name
 private_zone = true
}

resource "aws_route53_vpc_association_authorization" "private_zone_vpc_auth" {
provider = aws.core-network-services
for_each = data.aws_route53_zone.private.zone_id
vpc_id   = var.vpc_id
zone_id  = each.key
}

resource "aws_route53_zone_association" "private_zone_assoc"  {
vpc_id   = aws_route53_vpc_association_authorization.private_zone_vpc_auth.zone_id
zone_id  = aws_route53_vpc_association_authorization.private_zone_vpc_auth.vpc_id
}
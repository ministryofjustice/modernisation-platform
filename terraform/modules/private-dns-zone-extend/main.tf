
resource "aws_route53_vpc_association_authorization" "vpcauth" {
  for_each = var.zone_id
  vpc_id = var.vpc_id
  zone_id = each.value.id
}

resource "aws_route53_zone_association" "extend" {
  zone_id  = aws_route53_vpc_association_authorization.vpcauth.id
  vpc_id   = aws_route53_vpc_association_authorization.vpcauth.vpc_id
}

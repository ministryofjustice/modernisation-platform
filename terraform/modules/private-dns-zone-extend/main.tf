
data "aws_route53_zone" "private" {
 provider = core-network-services
 name = var.business_unit_name
}


resource "aws_route53_vpc_association_authorization" "vpcauth" {
provider = core-network-services
vpc_id   = var.vpc_id
zone_id  = data.aws_route53_zone.private.zone_id
}

resource "aws_route53_zone_association" "extend"  {
provider = core-network-services
vpc_id   = aws_route53_vpc_association_authorization.vpcauth.zone_id
zone_id  = aws_route53_vpc_association_authorization.vpcauth.vpc_id
}




# resource "aws_route53_vpc_association_authorization" "vpcauth" {
#   vpc_id = var.vpc_id
#   zone_id = var.zone_id
# }

# resource "aws_route53_zone_association" "extend" {
#   zone_id  = aws_route53_vpc_association_authorization.vpcauth.zone_id
#   vpc_id   = aws_route53_vpc_association_authorization.vpcauth.vpc_id
# }

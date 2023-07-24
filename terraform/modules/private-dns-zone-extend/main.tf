provider "aws" {
  alias = "core-network-services"
  version = "~> 2.0"
}

resource "aws_route53_vpc_association_authorization" "private_zone_vpc_auth" {
provider = aws.core-network-services
vpc_id   = var.vpc_id
zone_id  = var.business_unit_name
}

resource "aws_route53_zone_association" "private_zone_assoc"  {
vpc_id   = aws_route53_vpc_association_authorization.private_zone_vpc_auth.zone_id
zone_id  = aws_route53_vpc_association_authorization.private_zone_vpc_auth.vpc_id
}

output "zone_association_id" {
  value = aws_route53_zone_association.private_zone_assoc.id
}

# data "aws_route53_zone" "private" {
#  provider = aws.core-network-services
#  name = var.business_unit_name
# }

# resource "aws_route53_vpc_association_authorization" "vpcauth" {
#   vpc_id = var.vpc_id
#   zone_id = var.zone_id
# }

# resource "aws_route53_zone_association" "extend" {
#   zone_id  = aws_route53_vpc_association_authorization.vpcauth.zone_id
#   vpc_id   = aws_route53_vpc_association_authorization.vpcauth.vpc_id
# }

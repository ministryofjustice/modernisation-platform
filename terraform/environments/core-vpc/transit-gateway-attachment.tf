data "aws_ec2_transit_gateway" "transit-gateway" {
  provider = aws.core-network-services
  filter {
    name   = "options.amazon-side-asn"
    values = ["64589"]
  }
}

# Attach the VPC to the central Transit Gateway
module "vpc_attachment" {
  for_each = toset(keys(local.vpcs[terraform.workspace]))
  source   = "../../modules/ec2-tgw-attachment"
  providers = {
    aws.transit-gateway-tenant = aws
    aws.transit-gateway-host   = aws.core-network-services
  }

  resource_share_name = "transit-gateway"
  transit_gateway_id  = data.aws_ec2_transit_gateway.transit-gateway.id
  type                = local.tags.is-production ? "live_data" : "non_live_data"

  subnet_ids = module.vpc[each.key].tgw_subnet_ids
  vpc_id     = module.vpc[each.key].vpc_id
  vpc_name   = each.key

  tags = local.tags
}

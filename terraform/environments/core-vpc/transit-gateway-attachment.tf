# Assume a role in the core-network-services account
provider "aws" {
  alias  = "core-network-services"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/ModernisationPlatformAccess"
  }
}

# Create RAM principal assocation for this account
resource "aws_ram_principal_association" "transit_gateway_association" {
  provider = aws.core-network-services

  principal          = data.aws_caller_identity.current.account_id
  resource_share_arn = data.aws_ram_resource_share.transit-gateway-shared.arn
}

data "aws_ram_resource_share" "transit-gateway-shared" {
  provider = aws.core-network-services

  name           = "shared-transit-gateway"
  resource_owner = "SELF"
}

data "aws_ec2_transit_gateway" "transit-gateway" {
  provider = aws.core-network-services
  filter {
    name   = "options.amazon-side-asn"
    values = ["64589"]
  }
}

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}

# Create the VPC attachment in the second account...
module "vpc_attachment" {
  source = "../../modules/ec2-tgw-attachment"

  for_each = toset(keys(local.vpcs[terraform.workspace]))

  providers = {
    aws                       = aws
    aws.core-network-services = aws.core-network-services
  }

  depends_on = [
    aws_ram_principal_association.transit_gateway_association,
    time_sleep.wait_60_seconds
  ]

  subnet_ids = module.vpc[each.key].tgw_subnet_ids
  tgw_id     = data.aws_ec2_transit_gateway.transit-gateway.id
  vpc_id     = module.vpc[each.key].vpc_id
}

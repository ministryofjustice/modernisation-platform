# Get the environments file from the main repository
data "http" "environments_file" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.application_name}.json"
}

data "aws_ec2_transit_gateway" "transit-gateway" {
  provider = aws.core-network-services
  filter {
    name   = "options.amazon-side-asn"
    values = ["64589"]
  }
}

data "aws_ram_resource_share" "transit-gateway-shared" {
  provider = aws.core-network-services

  name           = "transit-gateway"
  resource_owner = "SELF"
}

# Look up the dedicated VPC by name tag
data "aws_vpc" "dedicated" {
  count = local.is-production ? 1 : 0

  tags = {
    Name = local.dedicated_vpc_name
  }
}

# Look up private subnets in the dedicated VPC for TGW attachment
data "aws_subnets" "dedicated_private" {
  count = local.is-production ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dedicated[0].id]
  }

  tags = {
    Name = "*private*"
  }
}

resource "aws_ram_resource_share" "shared-services" {
  provider = aws.core-network-services

  name                      = "shared-services"
  allow_external_principals = true

  tags = merge(
    local.tags,
    {
      Name = "shared-services"
    },
  )
}

data "aws_ec2_transit_gateway" "transit_gateway_id" {
  provider = aws.core-network-services

  filter {
    name   = "options.amazon-side-asn"
    values = ["64589"]
  }
}

# Share the transit gateway...
resource "aws_ram_resource_association" "ram-association" {
  provider = aws.core-network-services

  resource_arn       = data.aws_ec2_transit_gateway.transit_gateway_id.arn
  resource_share_arn = aws_ram_resource_share.shared-services.id
}

# ...with the second account.
resource "aws_ram_principal_association" "transit_gateway_association" {
  provider = aws.core-network-services

  principal          = data.aws_caller_identity.current.account_id
  resource_share_arn = aws_ram_resource_share.shared-services.arn
}


# this needs to sleep
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [aws_ram_principal_association.transit_gateway_association]
  create_duration = "60s"
}

resource "aws_ram_resource_share_accepter" "receiver_accept" {
  # provider = aws.core-network-services

  depends_on = [
    time_sleep.wait_60_seconds
  ]
  share_arn = aws_ram_principal_association.transit_gateway_association.resource_share_arn
}

# # Create the VPC attachment in the second account...
resource "aws_ec2_transit_gateway_vpc_attachment" "live" {

  depends_on = [
    aws_ram_principal_association.transit_gateway_association,
    aws_ram_resource_association.ram-association,
    aws_ram_resource_share_accepter.receiver_accept
  ]

  subnet_ids         = module.vpc["live"].tgw_subnet_ids
  transit_gateway_id = data.aws_ec2_transit_gateway.transit_gateway_id.id
  vpc_id             = module.vpc["live"].vpc_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "terraform-example"
    Side = "Creator"
  }
}
#
# # ...and accept it in the first account.
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "live" {
  provider = aws.core-network-services

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.live.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "terraform-example"
    Side = "Accepter"
  }
}

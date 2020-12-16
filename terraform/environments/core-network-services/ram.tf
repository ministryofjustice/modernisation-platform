# Create a resource share
resource "aws_ram_resource_share" "shared-transit-gateway" {
  name                      = "shared-transit-gateway"
  allow_external_principals = false

  tags = merge(
    local.tags,
    {
      Name = "shared-transit-gateway"
    },
  )
}

# Attach the Transit Gateway with the resource share
resource "aws_ram_resource_association" "ram-association" {
  resource_arn       = aws_ec2_transit_gateway.transit-gateway.arn
  resource_share_arn = aws_ram_resource_share.shared-transit-gateway.id
}

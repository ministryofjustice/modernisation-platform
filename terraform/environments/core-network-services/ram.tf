# Create a resource share for the Transit Gateway
resource "aws_ram_resource_share" "transit-gateway" {
  name                      = "transit-gateway"
  allow_external_principals = false

  tags = local.tags
}

# Attach the Transit Gateway to the resource share
resource "aws_ram_resource_association" "transit-gateway" {
  resource_arn       = aws_ec2_transit_gateway.transit-gateway.arn
  resource_share_arn = aws_ram_resource_share.transit-gateway.id
}

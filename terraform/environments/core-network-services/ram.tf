# Share the TGW
resource "aws_ram_resource_share" "shared-services" {
  name                      = "shared-services"
  allow_external_principals = false

  tags = merge(
    local.tags,
    {
      Name = "shared-services"
    },
  )
}

# Share the transit gateway...
resource "aws_ram_resource_association" "ram-association" {
  resource_arn       = aws_ec2_transit_gateway.TGW.arn
  resource_share_arn = aws_ram_resource_share.shared-services.id
}

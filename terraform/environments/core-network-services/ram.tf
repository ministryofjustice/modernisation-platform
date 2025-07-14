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

# Create a resource share for the Certificate Manager
resource "aws_ram_resource_share" "acm-pca-live" {
  name                      = "acm-pca-live"
  allow_external_principals = false

  tags = merge(
    local.tags,
    {
      Name = "acm-pca-live"
    },
  )
}

# Attach the Certificate Manager sub to the resource share
resource "aws_ram_resource_association" "acm-pca-live" {
  resource_arn       = aws_acmpca_certificate_authority.live_subordinate.arn
  resource_share_arn = aws_ram_resource_share.acm-pca-live.id
}

# Create a resource share for the Certificate Manager
resource "aws_ram_resource_share" "acm-pca-non-live" {
  name                      = "acm-pca-non-live"
  allow_external_principals = false

  tags = merge(
    local.tags,
    {
      Name = "acm-pca-non-live"
    },
  )
}

# Attach the Certificate Manager sub to the resource share
resource "aws_ram_resource_association" "acm-pca-non-live" {
  resource_arn       = aws_acmpca_certificate_authority.non-live_subordinate.arn
  resource_share_arn = aws_ram_resource_share.acm-pca-non-live.id
}

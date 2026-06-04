data "aws_ec2_transit_gateway" "transit-gateway" {
  provider = aws.core-network-services
  filter {
    name   = "options.amazon-side-asn"
    values = ["64589"]
  }
}

## Look up RAM Resource Share in the host account
data "aws_ram_resource_share" "transit-gateway" {
  provider = aws.core-network-services

  name           = "transit-gateway"
  resource_owner = "SELF"
}

## Get the Transit Gateway tenant account ID
data "aws_caller_identity" "transit-gateway-tenant" {
}

## Add the tenant account to the Transit Gateway Resource Share
## REMOVAL OF THIS RESOURCE WILL STOP ALL VPC ACCOUNT TRAFFIC VIA THE TRANSIT GATEWAY
resource "aws_ram_principal_association" "transit_gateway_association" {
  provider = aws.core-network-services

  principal          = data.aws_caller_identity.transit-gateway-tenant.account_id
  resource_share_arn = data.aws_ram_resource_share.transit-gateway.arn
}

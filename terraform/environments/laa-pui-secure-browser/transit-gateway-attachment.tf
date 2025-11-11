# Create RAM principal association for this account to access the Transit Gateway
# In order to allow LAA PUI service access via Secure Browser
# Only share with production account
resource "aws_ram_principal_association" "transit_gateway_association" {
  count    = local.is-production ? 1 : 0
  provider = aws.core-network-services

  principal          = data.aws_caller_identity.current.account_id
  resource_share_arn = data.aws_ram_resource_share.transit-gateway-shared.arn
}

# Attach the dedicated VPC to the Transit Gateway
# Note: You need to provide your VPC ID and subnet IDs
module "vpc_attachment" {
  count  = local.is-production ? 1 : 0
  source = "../../modules/ec2-tgw-attachment"

  providers = {
    aws.transit-gateway-tenant = aws
    aws.transit-gateway-host   = aws.core-network-services
  }

  transit_gateway_id = data.aws_ec2_transit_gateway.transit-gateway.id
  type               = "live_data" # Use "live_data" for production

  vpc_id     = data.aws_vpc.dedicated[0].id
  subnet_ids = data.aws_subnets.dedicated_private[0].ids
  vpc_name   = "${local.application_name}-${local.environment}"

  tags = merge(
    local.tags,
    { "Name" = "${local.application_name}-${local.environment}-attachment" }
  )

  depends_on = [
    aws_ram_principal_association.transit_gateway_association
  ]
}

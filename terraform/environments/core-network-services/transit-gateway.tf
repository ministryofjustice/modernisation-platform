module "transit-gateway-live" {
  source = "terraform-aws-modules/transit-gateway/aws"
  name   = "transit-gateway-london-live-01"

  # Disable default route table association and propogation
  enable_default_route_table_association = false
  enable_default_route_table_propagation = false

  # Enable auto-accepted shared attachments
  enable_auto_accept_shared_attachments = true

  # Resource Access Manager: Share with other AWS accounts
  ram_allow_external_principals = true
  ram_principals                = []

  # Attach VPCs to TGW
  vpc_attachments = {
    # Live VPC attachment
    live = {
      vpc_id = module.vpc-live.vpc_id

      # Get the subnet IDs for the private TGW subnets
      subnet_ids = [
        for subnet in data.aws_subnet.subnet-live :
        subnet.id
        if contains(local.private_tgw_cidr_blocks_live, subnet.cidr_block)
      ]

      # Turn on DNS support
      dns_support                                     = true

      # Turn off IPv6 support
      ipv6_support                                    = false

      # Disable default route table association and propogation
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      # Configure TGW routes
      tgw_routes = [
        {
          destination_cidr_block = "10.230.0.0/28"
        },
        {
          destination_cidr_block = "10.230.0.16/28"
        },
        {
          destination_cidr_block = "10.230.0.32/28"
        }
      ]
    }
  }

  # Tag the resource
  tags = local.tags
}

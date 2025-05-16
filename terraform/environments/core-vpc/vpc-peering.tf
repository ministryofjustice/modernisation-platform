# laa-portal-tactical
data "aws_vpc_peering_connections" "laa_portal_tactical_requestor" {
  filter {
    name   = "accepter-vpc-info.vpc-id"
    values = [module.vpc["laa-${local.environment}"].vpc_id]
  }
  filter {
    name = "requester-vpc-info.owner-id"
    values = [
      local.environment_management.account_ids["laa-portal-tactical-development"],
      local.environment_management.account_ids["laa-portal-tactical-production"]
    ]
  }
}

resource "aws_vpc_peering_connection_accepter" "laa_portal_tactical_accepter" {
  count                     = length(data.aws_vpc_peering_connections.laa_portal_tactical_requestor.ids) == 1 ? 1 : 0
  vpc_peering_connection_id = data.aws_vpc_peering_connections.laa_portal_tactical_requestor.ids[0]
  auto_accept               = true

  tags = merge(
    local.tags,
    {
      Side      = "Accepter",
      Requester = "LAA Tactical Portal ${local.environment}"
    }
  )
}

locals {
  peering_routes = {
    core-vpc-development = toset(["10.206.4.0/24", "10.206.5.0/24", "10.206.6.0/24"])
    core-vpc-production  = toset([])
  }
}

resource "aws_route" "portal_tactical_private" {
  for_each                  = lookup(local.peering_routes, terraform.workspace, toset([]))
  destination_cidr_block    = each.key
  route_table_id            = module.vpc["laa-${local.environment}"].private_route_tables.general-private
  vpc_peering_connection_id = data.aws_vpc_peering_connections.laa_portal_tactical_requestor.ids[0]
}

resource "aws_route" "portal_tactical_data" {
  for_each                  = lookup(local.peering_routes, terraform.workspace, toset([]))
  destination_cidr_block    = each.key
  route_table_id            = module.vpc["laa-${local.environment}"].private_route_tables.general-data
  vpc_peering_connection_id = data.aws_vpc_peering_connections.laa_portal_tactical_requestor.ids[0]
}

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

# laa-tactical-portal
# resource "aws_vpc_peering_connection_accepter" "laa_tactical_portal" {
#   vpc_peering_connection_id = data.aws_ssm_parameter.laa_tactical_portal_peering_id

#   tags = merge(
#     local.tags,
#     {
#       Side      = "Accepter",
#       Requester = "LAA Tactical Portal"
#     }
#   )
# }

resource "aws_ssm_parameter" "laa_tactical_portal_peering_id" {
  #checkov:skip=CKV_AWS_337: Standard key is fine here
  name = "laa_tactical_portal_peering_id"
  type = "SecureString"
  tags = local.tags
}

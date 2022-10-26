resource "aws_customer_gateway" "this" {
  for_each   = local.vpn_attachments
  bgp_asn    = each.value.bpg_asn
  ip_address = each.value.customer_gateway_ip
  type       = "ipsec.1"

  tags = merge(
    local.tags,
    { "Name" = replace(each.key, "_", "-") },
  )
}

resource "aws_vpn_connection" "this" {
  for_each                 = local.vpn_attachments
  transit_gateway_id       = aws_ec2_transit_gateway.transit-gateway.id
  customer_gateway_id      = aws_customer_gateway.this[each.key].id
  type                     = "ipsec.1"
  tunnel1_inside_cidr      = try(each.value.tunnel1_inside_cidr, null)
  tunnel2_inside_cidr      = try(each.value.tunnel2_inside_cidr, null)
  remote_ipv4_network_cidr = local.core-vpcs[each.value.modernisation_platform_vpc].cidr.subnet_sets["general"].cidr

  cloudwatch_log_options {
    log_enabled   = true
    log_group_arn = aws_cloudwatch_log_group.vpn_attachments.arn
  }

  tags = merge(
    local.tags,
    { "Name" = replace(each.key, "_", "-") },
  )

}

resource "aws_cloudwatch_log_group" "vpn_attachments" {
  for_each          = local.vpn_attachments
  name              = "${replace(each.key, "_", "-")}-vpn-attachment-logs"
  retention_in_days = 365
  tags              = local.tags
}

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

  tunnel1_log_options {
    cloudwatch_log_options {
      log_enabled   = true
      log_group_arn = aws_cloudwatch_log_group.vpn_attachments[each.key].arn
      log_output_format = "json"
    }
  }

  tunnel2_log_options {
    cloudwatch_log_options {
      log_enabled   = true
      log_group_arn = aws_cloudwatch_log_group.vpn_attachments[each.key].arn
      log_output_format = "json"
    }
  }

  tags = merge(
    local.tags,
    { "Name" = replace(each.key, "_", "-") },
  )

}

resource "aws_ec2_transit_gateway_route_table_association" "vpn_attachments" {
  for_each                       = local.vpn_attachments
  transit_gateway_attachment_id  = aws_vpn_connection.this[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_in.id
}

resource "aws_cloudwatch_log_group" "vpn_attachments" {
  # checkov:skip=CKV_AWS_158: "logs will not be shared so standard encryption fine"
  for_each          = local.vpn_attachments
  name              = "${replace(each.key, "_", "-")}-vpn-attachment-logs"
  retention_in_days = 365
  tags              = local.tags
}

resource "aws_dx_gateway_association_proposal" "this" {
  for_each = {
    for k, v in local.vpn_attachments : k => v
    if try((v.dx_gateway_id != ""), false)
  }
  dx_gateway_id               = try(each.value.dx_gateway_id, null)
  dx_gateway_owner_account_id = try(each.value.dx_gateway_owner_account_id, null)
  associated_gateway_id       = aws_customer_gateway.this[each.key].id
}

resource "aws_customer_gateway" "this" {
  for_each   = local.vpn_attachments
  bgp_asn    = each.value.bgp_asn
  ip_address = each.value.customer_gateway_ip
  type       = "ipsec.1"

  tags = merge(
    local.tags,
    { "Name" = replace(each.key, "_", "-") },
  )
}

resource "aws_vpn_connection" "this" {
  for_each                             = local.vpn_attachments
  transit_gateway_id                   = aws_ec2_transit_gateway.transit-gateway.id
  customer_gateway_id                  = aws_customer_gateway.this[each.key].id
  static_routes_only                   = try(each.value.static_routes_only, false)
  type                                 = "ipsec.1"
  tunnel1_dpd_timeout_action           = try(each.value.tunnel_dpd_timeout_action, null)
  tunnel1_dpd_timeout_seconds          = try(each.value.tunnel_dpd_timeout_seconds, "30")
  tunnel1_phase1_dh_group_numbers      = [try(each.value.tunnel_phase1_dh_group_numbers, null)]
  tunnel1_phase1_encryption_algorithms = [try(each.value.tunnel_phase1_encryption_algorithms, null)]
  tunnel1_phase1_integrity_algorithms  = [try(each.value.tunnel_phase1_integrity_algorithms, null)]
  tunnel1_phase1_lifetime_seconds      = try(each.value.tunnel_phase1_lifetime_seconds, null)
  tunnel1_phase2_dh_group_numbers      = [try(each.value.tunnel_phase2_dh_group_numbers, null)]
  tunnel1_phase2_encryption_algorithms = [try(each.value.tunnel_phase2_encryption_algorithms, null)]
  tunnel1_phase2_integrity_algorithms  = [try(each.value.tunnel_phase2_integrity_algorithms, null)]
  tunnel1_phase2_lifetime_seconds      = try(each.value.tunnel_phase2_lifetime_seconds, null)
  tunnel1_inside_cidr                  = try(each.value.tunnel1_inside_cidr, null)
  tunnel1_startup_action               = try(each.value.tunnel_startup_action, null)
  tunnel2_dpd_timeout_action           = try(each.value.tunnel_dpd_timeout_action, null)
  tunnel2_dpd_timeout_seconds          = try(each.value.tunnel_dpd_timeout_seconds, "30")
  tunnel2_phase1_dh_group_numbers      = [try(each.value.tunnel_phase1_dh_group_numbers, null)]
  tunnel2_phase1_encryption_algorithms = [try(each.value.tunnel_phase1_encryption_algorithms, null)]
  tunnel2_phase1_integrity_algorithms  = [try(each.value.tunnel_phase1_integrity_algorithms, null)]
  tunnel2_phase1_lifetime_seconds      = try(each.value.tunnel_phase1_lifetime_seconds, null)
  tunnel2_phase2_dh_group_numbers      = [try(each.value.tunnel_phase2_dh_group_numbers, null)]
  tunnel2_phase2_encryption_algorithms = [try(each.value.tunnel_phase2_encryption_algorithms, null)]
  tunnel2_phase2_integrity_algorithms  = [try(each.value.tunnel_phase2_integrity_algorithms, null)]
  tunnel2_phase2_lifetime_seconds      = try(each.value.tunnel_phase2_lifetime_seconds, null)
  tunnel2_inside_cidr                  = try(each.value.tunnel2_inside_cidr, null)
  tunnel2_startup_action               = try(each.value.tunnel_startup_action, null)
  remote_ipv4_network_cidr             = try(each.value.remote_ipv4_network_cidr, local.core-vpcs[each.value.modernisation_platform_vpc].cidr.subnet_sets["general"].cidr)

  tunnel1_log_options {
    cloudwatch_log_options {
      log_enabled       = true
      log_group_arn     = aws_cloudwatch_log_group.vpn_attachments[each.key].arn
      log_output_format = "json"
    }
  }

  tunnel2_log_options {
    cloudwatch_log_options {
      log_enabled       = true
      log_group_arn     = aws_cloudwatch_log_group.vpn_attachments[each.key].arn
      log_output_format = "json"
    }
  }

  tags = merge(
    local.tags,
    { "Name" = replace(each.key, "_", "-") },
  )

  lifecycle {
    ignore_changes = [
      tunnel1_ike_versions, tunnel1_phase1_dh_group_numbers, tunnel1_phase1_encryption_algorithms, tunnel1_phase1_integrity_algorithms,
      tunnel1_phase2_dh_group_numbers, tunnel1_phase2_encryption_algorithms, tunnel1_phase2_integrity_algorithms,
      tunnel2_ike_versions, tunnel2_phase1_dh_group_numbers, tunnel2_phase1_encryption_algorithms, tunnel2_phase1_integrity_algorithms,
      tunnel2_phase2_dh_group_numbers, tunnel2_phase2_encryption_algorithms, tunnel2_phase2_integrity_algorithms,
    ]
  }

}

resource "aws_ec2_transit_gateway_route_table_association" "vpn_attachments" {
  for_each                       = local.vpn_attachments
  transit_gateway_attachment_id  = aws_vpn_connection.this[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_in.id
}

# To prevent BGP routes from sending traffic via VPNs, we need static routes to override them
resource "aws_ec2_transit_gateway_route" "azure_static_routes" {
  for_each                       = toset(local.azure_static_routes)
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.pttp-tgw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_noms_routes_to_firewall" {
  depends_on                     = [aws_ec2_transit_gateway_route.azure_static_routes]
  for_each                       = local.noms_vpn_attachment_ids
  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

resource "aws_ec2_transit_gateway_route" "noms_dr_routes" {
  for_each                       = toset(local.noms_dr_vpn_static_routes)
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_vpn_connection.this["NOMS-Transit-Live-DR-VPN-VNG_1"].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

resource "aws_ec2_transit_gateway_route" "noms_live_routes" {
  for_each                       = toset(local.noms_live_vpn_static_routes)
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_vpn_connection.this["NOMS-Transit-Live-VPN-VNG_1"].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

resource "aws_ec2_transit_gateway_route" "parole_board_routes" {
  for_each                       = toset(local.parole_board_vpn_static_routes)
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_vpn_connection.this["Parole-Board-VPN"].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
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

# to be removed following merge of fix/rename-pttp-attachment branch

moved {
  from = aws_ec2_transit_gateway_peering_attachment_accepter.PTTP-Production
  to   = aws_ec2_transit_gateway_peering_attachment_accepter.moj_tgw_production
}

moved {
  from = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_live_data_to_PTTP["psn"]
  to   = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_live_data_to_moj["psn"]
}

moved {
  from = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_live_data_to_PTTP["rfc-1918-10.0.0.0/8"]
  to   = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_live_data_to_moj["rfc-1918-10.0.0.0/8"]
}

moved {
  from = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_live_data_to_PTTP["rfc-1918-172.16.0.0/12"]
  to   = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_live_data_to_moj["rfc-1918-172.16.0.0/12"]
}

moved {
  from = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_live_data_to_PTTP["rfc-1918-192.168.0.0/16"]
  to   = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_live_data_to_moj["rfc-1918-192.168.0.0/16"]
}

moved {
  from = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_non_live_data_to_PTTP["rfc-1918-10.0.0.0/8"]
  to   = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_non_live_data_to_moj["rfc-1918-10.0.0.0/8"]
}

moved {
  from = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_non_live_data_to_PTTP["rfc-1918-172.16.0.0/12"]
  to   = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_non_live_data_to_moj["rfc-1918-172.16.0.0/12"]
}

moved {
  from = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_non_live_data_to_PTTP["rfc-1918-192.168.0.0/16"]
  to   = aws_ec2_transit_gateway_route.tgw_external_egress_routes_for_non_live_data_to_moj["rfc-1918-192.168.0.0/16"]
}

moved {
  from = aws_flow_log.tgw_flowlog["PTTP-Transit-Gateway-attachment-accepter"]
  to   = aws_flow_log.tgw_flowlog["MOJ-TGW-attachment-accepter"]
}
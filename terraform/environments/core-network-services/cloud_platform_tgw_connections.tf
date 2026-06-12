
# CP Routing

locals {
  cloud-platform-attachments = {

    cloud-platform-development = {
      attachment_id  = "tgw-attach-0b0cca7618e009d38"
      cidr_range     = "10.195.32.0/20"
      route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
    }
  }
}


resource "aws_ec2_tag" "retag_cp_attachment" {
  for_each = local.cloud-platform-attachments

  resource_id = each.value.attachment_id

  key   = "Name"
  value = each.key
}

resource "aws_ec2_transit_gateway_route_table_association" "cp_nonlive_association" {
  for_each                       = local.cloud-platform-attachments
  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = each.value.route_table_id
}

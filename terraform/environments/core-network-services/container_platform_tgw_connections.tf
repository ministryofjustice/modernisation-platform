
# CP Routing

locals {
  container-platform-nonlive-attachments = {
    cloud-platform-development = {
      attachment_id = "tgw-attach-0b0cca7618e009d38"
    },
    cloud-platform-preproduction = {
      attachment_id = "tgw-attach-0dafba0c55531888f"
    },
    container-platform-octo-nonlive = {
      attachment_id = "tgw-attach-0e373debb35a1ecbd"
    }
  }

  container-platform-live-attachments = {
    cloud-platform-live = {
      attachment_id = "tgw-attach-04105db6caaa49915"
    },
    container-platform-octo-live = {
      attachment_id = "tgw-attach-05031a46f7a0d42ba"
    }
  }
}


resource "aws_ec2_tag" "retag_cp_attachment" {
  for_each    = local.container-platform-nonlive-attachments
  resource_id = each.value.attachment_id
  key         = "Name"
  value       = each.key
}

# Nonlive
resource "aws_ec2_transit_gateway_route_table_association" "cp_nonlive_association" {
  for_each                       = local.container-platform-nonlive-attachments
  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_cp_attachments_nonlive" {
  for_each                       = local.container-platform-nonlive-attachments
  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
}

# Live
resource "aws_ec2_transit_gateway_route_table_association" "cp_live_association" {
  for_each                       = local.container-platform-live-attachments
  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["live_data"].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_cp_attachments_live" {
  for_each                       = local.container-platform-live-attachments
  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["live_data"].id
}

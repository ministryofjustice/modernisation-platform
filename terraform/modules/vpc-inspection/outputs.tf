output "firewall" {
  value = aws_networkfirewall_firewall.inline_inspection
}

output "internet_gateway" {
  value = aws_internet_gateway.public
}

output "nat_gateway" {
  value = {
    for name, gateway in aws_nat_gateway.public :
    name => gateway
  }
}

output "route_table_ids" {
  value = {
    transit_gateway = {
      for name, table in aws_route_table.transit-gateway :
      name => table.id
    },
    inspection = {
      for name, table in aws_route_table.inspection :
      name => table.id
    },
    public = {
      for name, table in aws_route_table.public :
      name => table.id
    }
  }
}

output "subnet_attributes" {
  value = {
    transit_gateway = {
      for subnet_name, subnet_attrs in aws_subnet.transit-gateway :
      subnet_name => subnet_attrs[*]
    },
    inspection = {
      for subnet_name, subnet_attrs in aws_subnet.inspection :
      subnet_name => subnet_attrs[*]
    },
    public = {
      for subnet_name, subnet_attrs in aws_subnet.public :
      subnet_name => subnet_attrs[*]
    },
  }
}

output "transit_gateway_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.attachments-inspection.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cloudwatch_name" {
  value = aws_cloudwatch_log_group.main.name
}

output "fw_cloudwatch_name" {
  value = module.inline_inspection_logging.cloudwatch_log_group_name
}
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
      subnet_name => subnet_attrs.*
    },
    inspection = {
      for subnet_name, subnet_attrs in aws_subnet.inspection :
      subnet_name => subnet_attrs.*
    },
    public = {
      for subnet_name, subnet_attrs in aws_subnet.public :
      subnet_name => subnet_attrs.*
    },
  }
}

output "tgw_subnet_ids" {
  value = [for subnet in aws_subnet.transit-gateway : subnet.id]
}

output "vpc_id" {
  value = aws_vpc.main.id
}
output "firewall" {
  value = aws_networkfirewall_firewall.inline_inspection
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
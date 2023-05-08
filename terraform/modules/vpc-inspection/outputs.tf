output "subnet_attributes" {
  value = {
    for subnet_type in local.types :
    subnet_type => {
      for subnet, attributes in aws_subnet[subnet_type].* :
      subnet => attributes
    }
  }
}

output "firewall" {
  value = aws_networkfirewall_firewall.inline_inspection
}
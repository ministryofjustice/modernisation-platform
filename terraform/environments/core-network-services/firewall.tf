locals {
  external_inspection_vpc             = "10.56.0.0/24"
  external_inspection_subnet_in       = cidrsubnet(local.external_inspection_vpc, 2, 1)
  external_inspection_subnet_out      = cidrsubnet(local.external_inspection_vpc, 2, 0)
  external_inspection_in_subnets_map  = { for key, cidr in cidrsubnets(local.external_inspection_subnet_in, 2, 2, 2) : local.availability_zones[key] => cidr }
  external_inspection_out_subnets_map = { for key, cidr in cidrsubnets(local.external_inspection_subnet_out, 2, 2, 2) : local.availability_zones[key] => cidr }

}

#################
# VPC creation #
#################
# Ingress inspection VPC
resource "aws_vpc" "external_inspection" {

  cidr_block = local.external_inspection_vpc

  # Instance Tenancy
  instance_tenancy = "default"
  # DNS
  enable_dns_support   = false
  enable_dns_hostnames = false

  # Turn off IPv6
  assign_generated_ipv6_cidr_block = false

  tags = merge(
    local.tags,
    {
      Name = "external_inspection"
    }
  )
}

resource "aws_default_security_group" "external_inspection" {
  vpc_id = aws_vpc.external_inspection.id

  tags = merge(
    local.tags,
    {
      Name = "external_inspection"
    }
  )
}

#################
# VPC Flow Logs #
#################
# TF sec exclusions
# - Ignore warnings regarding log groups not encrypted using customer-managed KMS keys - following cost/benefit discussion and longer term plans for logging solution
#tfsec:ignore:AWS089
resource "aws_cloudwatch_log_group" "external_inspection" {
  #checkov:skip=CKV_AWS_158:Temporarily skip KMS encryption check while logging solution is being updated
  name              = "external-inspection-flow-logs"
  retention_in_days = 365 # 0 = never expire
  tags              = local.tags
}

resource "aws_flow_log" "external_inspection" {
  iam_role_arn             = data.aws_iam_role.vpc-flow-log.arn
  log_destination          = aws_cloudwatch_log_group.external_inspection.arn
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  max_aggregation_interval = "60"
  vpc_id                   = aws_vpc.external_inspection.id
  log_format               = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${pkt-srcaddr} $${pkt-dstaddr} $${flow-direction} $${traffic-path}"

  tags = merge(
    local.tags,
    {
      Name = "external-inspection-flow-logs"
    }
  )
}

########################
# Inspection VPC Subnets
########################
# Ingress Inspection in subnets
resource "aws_subnet" "external_inspection_in" {
  for_each = local.external_inspection_in_subnets_map

  vpc_id            = aws_vpc.external_inspection.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    local.tags,
    {
      Name = "external-inspection-in-${each.key}"
    }
  )
}
# Ingress Inspection out subnets
resource "aws_subnet" "external_inspection_out" {
  for_each = local.external_inspection_out_subnets_map

  vpc_id            = aws_vpc.external_inspection.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    local.tags,
    {
      Name = "external-inspection-out-${each.key}"
    }
  )
}

#################################
# Ingress Inspection VPC Routing
#################################
resource "aws_route_table" "external_inspection_in" {
  for_each = local.external_inspection_in_subnets_map

  vpc_id = aws_vpc.external_inspection.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.external_inspection.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.external_inspection_out[each.key].id], 0)
  }

  tags = merge(
    local.tags,
    {
      Name = "external-inspection_in_${each.key}"
    }
  )
}
resource "aws_route_table_association" "external_inspection_in" {
  for_each = local.external_inspection_in_subnets_map

  route_table_id = aws_route_table.external_inspection_in[each.key].id
  subnet_id      = aws_subnet.external_inspection_in[each.key].id
}

resource "aws_route_table" "external_inspection_out" {
  vpc_id = aws_vpc.external_inspection.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id
  }

  tags = merge(
    local.tags,
    {
      Name = "external-inspection_out"
    }
  )
}
resource "aws_route_table_association" "external_inspection_out" {
  for_each = local.external_inspection_in_subnets_map

  route_table_id = aws_route_table.external_inspection_out.id
  subnet_id      = aws_subnet.external_inspection_out[each.key].id
}
#  variable service {
#   type = string
#   default="default"
#  }

#   variable details {
#   type = string
#   default="default"
#  }
##############################
# 
##############################

# Get the json data and output it

locals {
  # get json 
 address-data = jsondecode(file("wanted-firewalls.json"))
  
  # get firewall requirements

  # for_each = to_set([ Wanted-Firewall in local.address-data.Wanted-Firewall.details ])

  # details = "${each.key}.local.each.value"
 var.address_definition = [for Wanted-Firewall in local.address-data.Wanted-Firewall : Wanted-Firewall.address_definition]
 var.source_port        = [for Wanted-Firewall in local.address-data.Wanted-Firewall : Wanted-Firewall.source_port]
 var.destination_port   = [for Wanted-Firewall in local.address-data.Wanted-Firewall : Wanted-Firewall.destination_port]
 var.protocols          = [for Wanted-Firewall in local.address-data.Wanted-Firewall : Wanted-Firewall.protocols]
 
 }
# data "get-incoming-IPs" "addresses" {
#   var.address_definition = [for Wanted-Firewall in local.address-data.Wanted-Firewall : Wanted-Firewall.address_definition]
#  var.source_port        = [for Wanted-Firewall in local.address-data.Wanted-Firewall : Wanted-Firewall.source_port]
#  var.destination_port   = [for Wanted-Firewall in local.address-data.Wanted-Firewall : Wanted-Firewall.destination_port]
#  var.protocols          = [for Wanted-Firewall in local.address-data.Wanted-Firewall : Wanted-Firewall.protocols]
#  }
# output "first_address_definition" {
#   value = element(split(",", local.address_definition[0]), 0)
# }
# output "first_source-port" {
#   value = element(split(",", local.source_port[0]), 2)
# }
# output "first_destination-port" {
#   value = element(split(",", local.destination_port[0]), 3)
# }
# output "first_protocol" {
#   value = element(split(",", local.protocols[0]), 0)
# }

# output "second_address_definition" {
#   value = element(split(",", local.address_definition[1]), 0)
# }
# output "second_source-port" {
#   value = element(split(",", local.source_port[1]), 2)
# }
# output "second_destination-port" {
#   value = element(split(",", local.destination_port[1]), 3)
# }
# output "second_protocol" {
#   value = element(split(",", local.protocols[1]), 0)
# }

# variable firewalls {

#    default = {
#        "address_definition_v": "10.40.0.0/18",
#        "source_port_v": "4",
#        "destination_port_v": "6",
#        "protocols_v": "8"
#    }
# }

#    nomis =     {
#      "address_definition_v": "10.40.0.0/18",
#      "from_port_v": "4",
#      "destination_port_v": "6",
#      "protocols_v": "8"
#  }

resource "aws_networkfirewall_firewall_policy" "external_inspection" {
  name = "external"

  firewall_policy {
    stateless_default_actions          = ["aws:drop"]
    stateless_fragment_default_actions = ["aws:drop"]
    stateless_rule_group_reference {
      priority     = 101
      resource_arn = aws_networkfirewall_rule_group.stateless_rules.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "stateless_rules" {
  description = "Stateless Rules"
  capacity    = 100
  name        = "stateless-rules"
  type        = "STATELESS"

  # provisioner "file" {
  #   source      = templatefile("firewalls.tftpl", var.firewalls)
  #   destination = "firewalls.json"
  # }


  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              source {
                address_definition = "10.40.0.0/18" # var.firewalls.address_definition_v
              }
              source_port {
                from_port = "1" # var.firewalls.from_port_v
                to_port   = "2" # var.firewalls.destination_port_v
              }
              destination {
                address_definition = "10.26.8.0/21" # Nomis-Test
              }
              destination_port {
                from_port = 80
                to_port   = 80
              }
              protocols = [6]
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "stateful_rules" {
  description = "Stateful Rules"
  capacity    = 100
  name        = "stateful_rules"
  type        = "STATEFUL"

  for_each = element(local.address_definition,1)
  IP-add = each.value
  rule_group {
    rule_variables {
      ip_sets {
        key = "WEBSERVERS_HOSTS"
        ip_set {
          definition = ["10.0.0.0/16", "10.0.1.0/24", "192.168.0.0/16"]
        }
      }
      ip_sets {
        key = "EXTERNAL_HOST"
        ip_set {
          definition = ["1.2.3.4/32"]
        }
      }
      port_sets {
        key = "HTTP_PORTS"
        port_set {
          definition = ["443", "80"]
        }
      }
      port_sets {
        key = "TCP_PORTS"
        port_set {
          definition = ["1", "65536"]
        }
      }
    }
    rules_source {
      #  rules_string = file("suricata_rules_file")
    }
  }
  tags = {
    Name = "Stateful test"
  }
}


resource "aws_networkfirewall_firewall" "external_inspection" {
  depends_on = [
    aws_subnet.external_inspection_out
  ]

  name                = "external-inspection"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.external_inspection.arn
  vpc_id              = aws_vpc.external_inspection.id
  subnet_mapping {
    subnet_id = aws_subnet.external_inspection_out["eu-west-2a"].id
  }
  subnet_mapping {
    subnet_id = aws_subnet.external_inspection_out["eu-west-2b"].id
  }
  subnet_mapping {
    subnet_id = aws_subnet.external_inspection_out["eu-west-2c"].id
  }

  tags = merge(
    local.tags,
    {
      Name = "external-inspection"
    }
  )

}

#################################
# TGW attach inspection vpc
#################################

# Attach external_inspection_in subnets to the Modernisation Platform Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "external_inspection_in" {

  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  # Attach subnets to the Transit Gateway
  vpc_id = aws_vpc.external_inspection.id
  subnet_ids = [
    for subnet in aws_subnet.external_inspection_in :
    subnet.id
  ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  # Enable DNS support
  dns_support = "disable"

  # Turn off IPv6 support
  ipv6_support = "disable"

  # Enable appliance mode support
  appliance_mode_support = "enable"

  tags = merge(
    local.tags,
    {
      Name = "inspection-attachment"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

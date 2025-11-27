locals {
  laa_vpc_keys = [
    "laa-production",
    "laa-preproduction",
    "laa-test",
    "laa-development"
  ]

  # SSH NACL rules specific to LAA VPCs. Note that these apply to all four shared vpcs, not just development.
  laa_ssh_acl_rules = {
    laa_development_subnet_a_ssh = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6010
    }
    laa_development_subnet_b_ssh = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6011
    }
    laa_development_subnet_c_ssh = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6012
    }
  }

  # Determine if the current VPC is in the LAA set
  apply_laa_ssh_rules = contains(local.laa_vpc_keys, var.vpc_name)

  # Only expose SSH rules for LAA environments
  laa_ssh_rules_to_apply = local.apply_laa_ssh_rules ? local.laa_ssh_acl_rules : {}


  # LAA Custom Egress Ports

  laa_custom_egress_tcp_acl_rules = {
    laa_general_private_subnet_a_ftp_custom = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 8022
      to_port     = 8022
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6050
    }
    laa_general_private_subnet_b_ftp_custom = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 8022
      to_port     = 8022
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6051
    }
    laa_general_private_subnet_c_ftp_custom = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 8022
      to_port     = 8022
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6052
    }
  }

  apply_laa_custom_tcp_rules = contains(local.laa_vpc_keys, var.vpc_name)

  laa_custom_tcp_rules_to_apply = local.apply_laa_custom_tcp_rules ? local.laa_custom_egress_tcp_acl_rules : {}



# Custom Rules for access to selected CICA subnets from AP

  cica_vpc_keys = [
    "cica-development",
    "cica-production"
  ]

cica_general_private_ap_access_rules = {
  cica_general_private_subnets_ap_db = {
    cidr_block  = "10.27.128.28/32"
    egress      = false
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    rule_action = "allow"
    rule_number = 2015
  }
}

apply_cica_ap_rules = contains(local.cica_vpc_keys, var.vpc_name)

cica_db_rules_to_apply = local.apply_cica_ap_rules ? local.cica_general_private_ap_access_rules : {}


}

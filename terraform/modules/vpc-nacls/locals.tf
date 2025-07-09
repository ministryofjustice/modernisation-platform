locals {
  laa_vpc_keys = [
    "laa-production",
    "laa-preproduction",
    "laa-test",
    "laa-development"
  ]

  # SSH NACL rules specific to LAA VPCs
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
        laa_development_subnet_a_ftp_custom = {
        cidr_block  = "0.0.0.0/0"
        egress      = true
        from_port   = 8022
        to_port     = 8022
        protocol    = "tcp"
        rule_action = "allow"
        rule_number = 6050
      }
      laa_development_subnet_b_ftp_custom = {
        cidr_block  = "0.0.0.0/0"
        egress      = true
        from_port   = 8022
        to_port     = 8022
        protocol    = "tcp"
        rule_action = "allow"
        rule_number = 6051
      }
      laa_development_subnet_c_ftp_custom = {
        cidr_block  = "0.0.0.0/0"
        egress      = true
        from_port   = 8022
        to_port     = 8022
        protocol    = "tcp"
        rule_action = "allow"
        rule_number = 6052
      }
      laa_production_subnet_a_ftp_custom = {
        cidr_block  = "0.0.0.0/0"
        egress      = true
        from_port   = 8022
        to_port     = 8022
        protocol    = "tcp"
        rule_action = "allow"
        rule_number = 6050
      }
      laa_production_subnet_b_ftp_custom = {
        cidr_block  = "0.0.0.0/0"
        egress      = true
        from_port   = 8022
        to_port     = 8022
        protocol    = "tcp"
        rule_action = "allow"
        rule_number = 6051
      }
      laa_production_subnet_c_ftp_custom = {
        cidr_block  = "0.0.0.0/0"
        egress      = true
        from_port   = 8022
        to_port     = 8022
        protocol    = "tcp"
        rule_action = "allow"
        rule_number = 6052
      }
  }

  apply_laa_custom_tcp_rules = contains(local.laa_custom_egress_tcp_acl_rules, var.vpc_name)

  laa_custom_tcp_rules_to_apply = local.apply_laa_custom_tcp_rules ? local.laa_custom_egress_tcp_acl_rules : {}

}

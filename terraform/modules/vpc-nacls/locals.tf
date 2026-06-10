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

  cica_vpc_keys = {
    cica-development = {
      cidr_block = "10.26.128.0/23"
    }
    cica-production = {
      cidr_block = "10.27.128.0/23"
    }
  }

  cica_general_private_ap_access_rules_base = {
    cica_general_private_subnets_ap_db_ingress = {
      egress      = false
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 2015
    }
    # Note - egress ports are ephemeral and so need to wider in scope than just 1521.
    cica_general_private_subnets_ap_db_egress = {
      egress      = true
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 2015
    }
  }

  apply_cica_ap_rules = contains(keys(local.cica_vpc_keys), var.vpc_name)

  cica_db_rules_to_apply = local.apply_cica_ap_rules ? {
    for rule_key, rule in local.cica_general_private_ap_access_rules_base :
    rule_key => merge(
      rule,
      { cidr_block = local.cica_vpc_keys[var.vpc_name].cidr_block }
    )
  } : {}

# Custom Rules for Outbound HMPPS Rules

  hmpps_vpc_keys = {
    hmpps-production-a = {
      cidr_block = "165.72.0.0/16",
      rule_number = 6010
    }
    hmpps-production-b = {
      cidr_block = "199.40.0.0/16",
      rule_number = 6011

    }
  }

  hmpps_general_access_rules_base = {
    hmpps_general_access_rules_egress = {
      egress      = true
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      rule_action = "allow"
    }
  }

  apply_hmpps_ap_rules = anytrue([for key in keys(local.hmpps_vpc_keys) : strcontains(key, var.vpc_name)])

  hmpps_rules_to_apply = merge([
    for vpc_key, vpc_data in local.hmpps_vpc_keys : strcontains(vpc_key, var.vpc_name) ? {
      for rule_key, rule in local.hmpps_general_access_rules_base :
      "${rule_key}_${vpc_key}" => merge(
        rule,
        {
          cidr_block  = vpc_data.cidr_block
          rule_number = vpc_data.rule_number
        }
      )
    } : {}
  ]...)

}

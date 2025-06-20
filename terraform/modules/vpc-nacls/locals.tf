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
      cidr_block  = "13.17.132.44/32"
      egress      = true
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6010
    }
    laa_development_subnet_b_ssh = {
      cidr_block  = "13.17.132.44/32"
      egress      = true
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6011
    }
    laa_development_subnet_c_ssh = {
      cidr_block  = "13.17.132.44/32"
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
}

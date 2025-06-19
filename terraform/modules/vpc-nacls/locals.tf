locals {
  laa_ssh_acl_rules = {
    laa_development_subnet_a_ssh = {
      cidr_block  = "13.17.132.44/32" # destination IP
      egress      = true
      from_port   = 22
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6010
      to_port     = 22
    }
    laa_development_subnet_b_ssh = {
      cidr_block  = "13.17.132.44/32"
      egress      = true
      from_port   = 22
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6011
      to_port     = 22
    }
    laa_development_subnet_c_ssh = {
      cidr_block  = "13.17.132.44/32"
      egress      = true
      from_port   = 22
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6012
      to_port     = 22
    }
  }
}

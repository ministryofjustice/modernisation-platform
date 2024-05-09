locals {
  # 1000 = intra-vpc traffic
  # 2000 = inter-vpc traffic (dynamic rules)
  # 3000 = deny east-west
  # 4000 = private address ranges
  # 5000 = internet access
  # 6000 = public address ranges (dynamic)
  # 7000 = access from internet

  static_acl_rules = {
    allow_vpc_cidr_in = {
      cidr_block  = var.vpc_cidr
      egress      = false
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 1000
      to_port     = null
    },
    allow_vpc_cidr_out = {
      cidr_block  = var.vpc_cidr
      egress      = true
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 1000
      to_port     = null
    },
    allow_all_out = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 5000
      to_port     = null
    },
    allow_all_in = {
      cidr_block  = "0.0.0.0/0"
      egress      = false
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 5000
      to_port     = null
    }
  }
}
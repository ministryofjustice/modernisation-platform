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
    allow_10-0-0-0_in = {
      cidr_block  = "10.0.0.0/8"
      egress      = false
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4000
      to_port     = null
    },
    allow_10-0-0-0_out = {
      cidr_block  = "10.0.0.0/8"
      egress      = true
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4000
      to_port     = null
    },
    allow_172-16-0-0_in = {
      cidr_block  = "172.16.0.0/12"
      egress      = false
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4100
      to_port     = null
    },
    allow_172-16-0-0_out = {
      cidr_block  = "172.16.0.0/12"
      egress      = true
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4100
      to_port     = null
    },
    allow_192-168-0-0_in = {
      cidr_block  = "192.168.0.0/16"
      egress      = false
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4200
      to_port     = null
    },
    allow_192-168-0-0_out = {
      cidr_block  = "192.168.0.0/16"
      egress      = true
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4200
      to_port     = null
    },
    allow_0-0-0-0_https_out = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 443
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 5000
      to_port     = 443
    },
    allow_0-0-0-0_http_out = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 80
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 5100
      to_port     = 80
    },
    allow_0-0-0-0_smtp_465_tcp_out = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 465
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 5200
      to_port     = 465
    },
    allow_0-0-0-0_smtp_submission_tcp_out = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 587
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 5300
      to_port     = 587
    },
    allow_0-0-0-0_agent_tcp_out = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = 5721
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 5400
      to_port     = 5721
    },
    allow_0-0-0-0_dynamic_tcp_in = {
      cidr_block  = "0.0.0.0/0"
      egress      = false
      from_port   = 1024
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 5100
      to_port     = 65535
    }
  }

  public_access_acl_rules = {
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
    allow_https_in = {
      cidr_block  = "0.0.0.0/0"
      egress      = false
      from_port   = 443
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 7000
      to_port     = 443
    },
    deny_remote-desktop_tcp_in = {
      cidr_block  = "0.0.0.0/0"
      egress      = false
      from_port   = 3389
      protocol    = "tcp"
      rule_action = "deny"
      rule_number = 7100
      to_port     = 3389
    },
    allow_dynamic_tcp_in = {
      cidr_block  = "0.0.0.0/0"
      egress      = false
      from_port   = 1024
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 7200
      to_port     = 65535
    },
    allow_dynamic_udp_in = {
      cidr_block  = "0.0.0.0/0"
      egress      = false
      from_port   = 1024
      protocol    = "udp"
      rule_action = "allow"
      rule_number = 7300
      to_port     = 65535
    },
    allow_any_out = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 7000
      to_port     = null
    }
  }

}
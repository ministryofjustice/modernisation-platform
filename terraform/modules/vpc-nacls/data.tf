data "aws_vpc" "current" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_vpc" "external" {
  for_each = toset(var.additional_vpcs)
  filter {
    name   = "tag:Name"
    values = [each.key]
  }
}

data "aws_subnets" "subnets_all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.current.id]
  }
}

data "aws_subnet" "subnets_all" {
  for_each = toset(data.aws_subnets.subnets_all.ids)
  id       = each.value
}

locals {
  data_subnet_ids      = [for v in data.aws_subnet.subnets_all : v.id if(length(regexall("(?:data)", v.tags.Name)) > 0)]
  private_subnet_ids   = [for v in data.aws_subnet.subnets_all : v.id if(length(regexall("(?:private)", v.tags.Name)) > 0)]
  protected_subnet_ids = [for v in data.aws_subnet.subnets_all : v.id if(length(regexall("(?:protected)", v.tags.Name)) > 0)]
  public_subnet_ids    = [for v in data.aws_subnet.subnets_all : v.id if(length(regexall("(?:public)", v.tags.Name)) > 0)]

  external_vpc_cidrs = length(var.additional_vpcs) > 0 ? flatten([
    for v in data.aws_vpc.external : {
    cidr_block = v.cidr_block }
  ]) : []

  external_range_cidrs = length(var.additional_cidrs) > 0 ? flatten([
    for v in var.additional_cidrs : {
    cidr_block = v }
  ]) : []

  static_acl_rules = {
    allow_vpc_cidr_in = {
      cidr_block  = data.aws_vpc.current.cidr_block
      egress      = false
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 1000
    },
    allow_vpc_cidr_out = {
      cidr_block  = data.aws_vpc.current.cidr_block
      egress      = true
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 1000
    },
    deny_mp_cidr_in = {
      cidr_block  = "10.26.0.0/15"
      egress      = false
      protocol    = "-1"
      rule_action = "deny"
      rule_number = 3000
    },
    deny_mp_cidr_out = {
      cidr_block  = "10.26.0.0/15"
      egress      = true
      protocol    = "-1"
      rule_action = "deny"
      rule_number = 3000
    },
    allow_10-0-0-0_in = {
      cidr_block  = "10.0.0.0/8"
      egress      = false
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4000
    },
    allow_10-0-0-0_out = {
      cidr_block  = "10.0.0.0/8"
      egress      = true
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4000
    },
    allow_172-16-0-0_in = {
      cidr_block  = "172.16.0.0/12"
      egress      = false
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4100
    },
    allow_172-16-0-0_out = {
      cidr_block  = "172.16.0.0/12"
      egress      = true
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4100
    },
    allow_192-168-0-0_in = {
      cidr_block  = "192.168.0.0/16"
      egress      = false
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4200
    },
    allow_192-168-0-0_out = {
      cidr_block  = "192.168.0.0/16"
      egress      = true
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 4200
    },
  }

  public_access_acl_rules = {
    allow_https_in = {
      cidr_block  = "0.0.0.0/0"
      egress      = false
      from_port   = 443
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6000
      to_port     = 443
    },
    allow_dynamic_tcp_in = {
      cidr_block  = "0.0.0.0/0"
      egress      = false
      from_port   = 1024
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 6100
      to_port     = 65535
    },
    allow_dynamic_udp_in = {
      cidr_block  = "0.0.0.0/0"
      egress      = false
      from_port   = 1024
      protocol    = "udp"
      rule_action = "allow"
      rule_number = 6200
      to_port     = 65535
    },
    allow_any_out = {
      cidr_block  = "0.0.0.0/0"
      egress      = true
      from_port   = null
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 6000
      to_port     = null
    }
  }

  endpoint_access_rules = {
    allow_https_in = {
      cidr_block  = data.aws_vpc.current.cidr_block
      egress      = false
      from_port   = 443
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 1000
      to_port     = 443
    },
    allow_smtp-tls_in = {
      cidr_block  = data.aws_vpc.current.cidr_block
      egress      = false
      from_port   = 587
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 1100
      to_port     = 587
    },
    allow_dynamic_tcp_out = {
      cidr_block  = data.aws_vpc.current.cidr_block
      egress      = true
      from_port   = 1024
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 1000
      to_port     = 65535
    }
  }

}
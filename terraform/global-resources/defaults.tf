# VPC
resource "aws_default_vpc" "default" {
  tags = local.global_resources
}

# Subnets
resource "aws_default_subnet" "default_aza" {
  availability_zone = "eu-west-2a"
  tags              = local.global_resources
}

resource "aws_default_subnet" "default_azb" {
  availability_zone = "eu-west-2b"
  tags              = local.global_resources
}

resource "aws_default_subnet" "default_azc" {
  availability_zone = "eu-west-2c"
  tags              = local.global_resources
}

# DHCP options
resource "aws_default_vpc_dhcp_options" "default" {
  tags = local.global_resources
}

# Network ACL
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_default_vpc.default.default_network_acl_id
  subnet_ids = [
    aws_default_subnet.default_aza.id,
    aws_default_subnet.default_azb.id,
    aws_default_subnet.default_azc.id
  ]

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = local.global_resources
}

# Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.global_resources
}

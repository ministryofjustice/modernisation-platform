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

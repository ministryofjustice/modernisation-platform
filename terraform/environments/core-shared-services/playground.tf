# Sharing
provider "aws" {
  alias  = "core-vpc-non-live-data"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-vpc-non-live-data"]}:role/ModernisationPlatformAccess"
  }
}

# Share the core VPC with this account
resource "aws_ram_principal_association" "vpc-non-live-data-shared" {
  provider = aws.core-vpc-non-live-data

  principal          = data.aws_caller_identity.current.account_id
  resource_share_arn = data.aws_ram_resource_share.vpc-non-live-data-shared.arn
}

data "aws_ram_resource_share" "vpc-non-live-data-shared" {
  provider       = aws.core-vpc-non-live-data
  name           = "core-vpc-non-live-data-to-hmpps-vpc-non-live-data"
  resource_owner = "SELF"
}

# EC2

# Lookup shared VPC details
locals {
  shared_vpc_cidr = "10.232.128.0/18"
}

data "aws_vpc" "shared-from-core-vpc-non-live-data" {
  cidr_block = local.shared_vpc_cidr
}

# Lookup shared VPC subnets
data "aws_subnet" "shared-from-core-vpc-non-live-data" {
  cidr_block = "10.232.152.0/22"
}

# Create instance in the shared VPC
resource "aws_instance" "test" {
  ami           = "ami-08b993f76f42c3e2f" # AWS Linux 2 AMI
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.shared-from-core-vpc-non-live-data.id
  key_name      = aws_key_pair.bastion_key.key_name

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]

  tags = merge(
    local.tags,
    {
      Name = "playground.tf"
    }
  )
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "deployer-key"
  public_key = "[redacted]" # I've removed this and added a lifecycle {} block below which will ignore changes. Feel free to remove the lifecycle block and update the public key as required, but it saved me committing my key to GitHub.

  tags = merge(
    local.tags,
    {
      Name = "playground.tf"
    }
  )

  lifecycle {
    ignore_changes = [public_key]
  }
}

# SG
resource "aws_security_group" "default" {
  name   = "allow_ssh"
  vpc_id = data.aws_vpc.shared-from-core-vpc-non-live-data.id

  tags = merge(
    local.tags,
    {
      Name = "playground.tf"
    }
  )
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.shared_vpc_cidr]       # from core-vpc-non-live-data
  security_group_id = aws_security_group.default.id # from core-network-services
}

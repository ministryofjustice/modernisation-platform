data "aws_vpc" "shared" {
  tags = {
    "Name" = "${var.networking[0].business-unit}-${local.environment}"
  }
}

data "aws_subnets" "shared-data" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }
  tags = {
    Name = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-data*"
  }
}

data "aws_subnet" "private_subnets_a" {
  vpc_id = data.aws_vpc.shared.id
  tags = {
    "Name" = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-private-${local.app_data.accounts[local.environment].region}a"
  }
}

data "aws_subnet" "private_subnets_b" {
  vpc_id = data.aws_vpc.shared.id
  tags = {
    "Name" = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-private-${local.app_data.accounts[local.environment].region}b"
  }
}

data "aws_subnet" "private_subnets_c" {
  vpc_id = data.aws_vpc.shared.id
  tags = {
    "Name" = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-private-${local.app_data.accounts[local.environment].region}c"
  }
}

data "aws_subnet" "public_az_a" {
  vpc_id = data.aws_vpc.shared.id
  tags = {
    Name = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-public-${local.app_data.accounts[local.environment].region}a"
  }
}

data "aws_subnet" "public_az_b" {
  vpc_id = data.aws_vpc.shared.id
  tags = {
    Name = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-public-${local.app_data.accounts[local.environment].region}b"
  }
}

data "aws_subnet" "public_az_c" {
  vpc_id = data.aws_vpc.shared.id
  tags = {
    Name = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-public-${local.app_data.accounts[local.environment].region}c"
  }
}

data "aws_route53_zone" "external" {
  provider = aws.core-vpc

  name         = "${var.networking[0].business-unit}-${local.environment}.modernisation-platform.service.justice.gov.uk."
  private_zone = false
}

data "aws_route53_zone" "inner" {
  provider = aws.core-vpc

  name         = "${var.networking[0].business-unit}-${local.environment}.modernisation-platform.internal."
  private_zone = true
}

data "aws_route53_zone" "network-services" {
  provider = aws.core-network-services

  name         = "modernisation-platform.service.justice.gov.uk."
  private_zone = false
}

data "aws_subnets" "shared-public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }
  tags = {
    Name = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-public*"
  }
}

data "terraform_remote_state" "core_network_services" {
  backend = "s3"
  config = {
    acl     = "bucket-owner-full-control"
    bucket  = "modernisation-platform-terraform-state"
    key     = "environments/accounts/core-network-services/core-network-services-production/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

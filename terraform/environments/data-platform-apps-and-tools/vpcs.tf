module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name            = "data-platform-${local.environment}"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  cidr            = local.environment_configuration.vpc_cidr
  private_subnets = local.environment_configuration.vpc_private_subnets
  public_subnets  = local.environment_configuration.vpc_public_subnets

  enable_nat_gateway     = local.environment_configuration.vpc_enable_nat_gateway
  one_nat_gateway_per_az = local.environment_configuration.vpc_one_nat_gateway_per_az

  enable_flow_log                           = true
  create_flow_log_cloudwatch_log_group      = true
  create_flow_log_cloudwatch_iam_role       = true
  flow_log_cloudwatch_log_group_name_suffix = "data-platform-${local.environment}"

  tags = local.tags
}

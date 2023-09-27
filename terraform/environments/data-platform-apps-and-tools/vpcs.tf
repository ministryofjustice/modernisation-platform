#tfsec:ignore:aws-ec2-no-public-ingress-acl
#tfsec:ignore:aws-ec2-no-excessive-port-access
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
module "vpc" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name             = "${local.application_name}-${local.environment}"
  azs              = slice(data.aws_availability_zones.available.names, 0, 3)
  cidr             = local.environment_configuration.vpc_cidr
  private_subnets  = local.environment_configuration.vpc_private_subnets
  public_subnets   = local.environment_configuration.vpc_public_subnets
  database_subnets = local.environment_configuration.vpc_database_subnets

  enable_nat_gateway     = local.environment_configuration.vpc_enable_nat_gateway
  one_nat_gateway_per_az = local.environment_configuration.vpc_one_nat_gateway_per_az

  enable_flow_log                           = true
  create_flow_log_cloudwatch_log_group      = true
  create_flow_log_cloudwatch_iam_role       = true
  flow_log_cloudwatch_log_group_name_suffix = "${local.application_name}-${local.environment}"

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

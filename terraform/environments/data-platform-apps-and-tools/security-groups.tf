module "smtp_vpc_endpoint_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2517eb98a39500897feecd27178994055ee2eb5e"

  name        = "${local.application_name}-${local.environment}-smtp-vpc-endpoint"
  description = "SMTP VPC Endpoint"

  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_rules       = ["smtp-submission-587-tcp"]

  tags = local.tags
}

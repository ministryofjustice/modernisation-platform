
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "2517eb98a39500897feecd27178994055ee2eb5e"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    email-smtp = {
      service             = "email-smtp"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [module.smtp_vpc_endpoint_security_group.security_group_id]
      private_dns_enabled = true
      tags                = { Name = "${local.application_name}-${local.environment}-smtp" }
    }
  }

  tags = local.tags
}

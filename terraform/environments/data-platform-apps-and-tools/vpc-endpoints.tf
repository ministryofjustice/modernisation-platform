module "vpc_endpoints" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    email-smtp = {
      service             = "email-smtp"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [module.smtp_vpc_endpoint_security_group.security_group_id]
      private_dns_enabled = true
      tags                = { Name = "${local.application_name}-${local.environment}-smtp" }
    }
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.private_route_tables,
        module.vpc.public_route_tables,
      ])
      tags = { Name = "${local.application_name}-${local.environment}-s3" }
    }
  }

  tags = local.tags
}

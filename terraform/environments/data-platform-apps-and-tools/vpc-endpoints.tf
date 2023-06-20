#tfsec:aws-ec2-no-public-ingress-acl
#tfsec:ignore:aws-ec2-no-excessive-port-access
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "4.0.2"

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

module "smtp_vpc_endpoint_security_group" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.application_name}-${local.environment}-smtp-vpc-endpoint"
  description = "SMTP VPC Endpoint"

  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_rules       = ["smtp-submission-587-tcp"]

  tags = local.tags
}

#Open outbound rule in line with AWS documented recommendation
#tfsec:ignore:aws-ec2-no-public-egress-sgr
module "mwaa_security_group" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${local.application_name}-${local.environment}-mwaa"
  vpc_id = module.vpc.vpc_id

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]

  tags = local.tags
}

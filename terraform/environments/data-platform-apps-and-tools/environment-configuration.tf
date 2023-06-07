locals {
  environment_configuration = local.environment_configurations[local.environment]
  environment_configurations = {
    development = {
      ses_domain_identity        = "apps-tools.${local.environment}.data-platform.service.justice.gov.uk"
      vpc_cidr                   = "10.27.128.0/24"
      vpc_private_subnets        = ["10.26.128.0/26", "10.26.128.16/26", "10.26.128.32/26"]
      vpc_public_subnets         = ["10.26.128.48/26", "10.26.128.64/26", "10.26.128.80/26"]
      vpc_enable_nat_gateway     = true
      vpc_one_nat_gateway_per_az = false
    }
  }
}

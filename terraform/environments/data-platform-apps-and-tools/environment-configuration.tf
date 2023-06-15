locals {
  environment_configuration = local.environment_configurations[local.environment]
  environment_configurations = {
    development = {
      ses_domain_identity        = "apps-tools.${local.environment}.data-platform.service.justice.gov.uk"
      vpc_cidr                   = "10.27.128.0/23"
      vpc_private_subnets        = ["10.27.128.0/26", "10.27.128.64/26", "10.27.128.128/26"]
      vpc_public_subnets         = ["10.27.129.0/26", "10.27.129.64/26", "10.27.129.128/26"]
      vpc_enable_nat_gateway     = true
      vpc_one_nat_gateway_per_az = false
    }
  }
}

locals {
  production-vpc = {
    live = {
      cidr = {
        vpc = "10.232.0.0/18"
        subnets = {
          tgw = [
            "10.232.48.0/28",
			      "10.232.48.16/28",
			      "10.232.48.32/28"
          ]
          private = [
            "10.232.0.0/21",
			      "10.232.8.0/21",
			      "10.232.16.0/21"
          ]
          dmz = [
            "10.232.24.0/22",
			      "10.232.28.0/22",
		      	"10.232.32.0/22"
          ]
          data = [
           "10.232.36.0/22",
			     "10.232.40.0/22",
			     "10.232.44.0/22"
          ]
        }
      }
    }
  }
    non_live_data-vpc = {
      non-live = {
       cidr = {
        vpc = "10.232.128.0/18"
        subnets = {
          tgw = [
            "10.232.176.0/28",
			      "10.232.176.16/28",
			      "10.232.176.32/28"
          ]
          private = [
            "10.232.128.0/21",
			      "10.232.136.0/21",
			      "10.232.144.0/21"
          ]
          dmz = [
           "10.230.152.0/22",
			     "10.230.156.0/22",
			     "10.230.160.0/22"
          ]
          data = [
           "10.232.164.0/22",
			     "10.232.168.0/22",
		       "10.232.172.0/22"
          ]
        }
      }
    }
  }
  

  useful_vpc_ids = {
    for key in keys(local.production-vpc) :
    key => {
      vpc_id                 = module.vpc[key].vpc_id
      private_tgw_subnet_ids = module.vpc[key].tgw_subnet_ids
    }
  }
}

module "vpc" {
  for_each = terraform.workspace == "core-vpc-production" ? local.production-vpc : {}
  
  source   = "../../modules/core-vpc"

  # CIDRs
  subnet_cidrs_by_type = each.value.cidr.subnets
  vpc_cidr             = each.value.cidr.vpc

  # NAT Gateway
  enable_nat_gateway = false

  # Tags
  tags_common = {}
  tags_prefix = each.key
}


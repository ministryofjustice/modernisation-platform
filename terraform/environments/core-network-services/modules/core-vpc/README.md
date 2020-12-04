# Core VPC Creation

Terraform module for creating core VPC - also provisions Transit Gateway subnets

## Usage

```
module "vpc" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/ebs"
}
```

## Inputs
|                Name                |                           Description                           |  Type  | Default | Required |
|:----------------------------------:|:---------------------------------------------------------------:|:------:|:-------:|----------|
|             vpc_cidr               |         CIDR range to be used for vpc creation                  | string |   n/a   | yes      |
|      private_tgw_cidr_blocks       |         CIDR range to be used for Transit Gateway subnets       |  list  |   n/a   | yes      |
|        private_cidr_blocks         |         CIDR range to be used for private subnets               |  list  |   n/a   | yes      |
|         public_cidr_blocks         |         CIDR range to be used for public subnets                |  list  |   n/a   | yes      |
|            tags_common             |         Common MOJ tags to be used for all resources            |  map   |   n/a   | yes      |
|            tags_prefix             |         Prefix for all resource names                           | string |   n/a   | yes      |

## Outputs
|                Name                |                           Description                           |  Type  |
|:----------------------------------:|:---------------------------------------------------------------:|:------:|
|  vpc_id                            | VPC id                                                          | string |
|  private_tgw_subnet_ids            | private subnets ids for Transit Gateway connections             | string |

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

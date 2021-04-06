# DNS Zone creation

Terraform module for creating core DNS zones

## Usage

```
module "vpc" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/??????"
}
```


## Inputs
|                Name                |                           Description                           |  Type  |
|:----------------------------------:|:---------------------------------------------------------------:|:------:|
|  vpc_id                            | VPC id                                                          | string |
|  dns_zone                            DNS zone                                                        | string |

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

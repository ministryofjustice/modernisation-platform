# modernisation-platform-terraform-vpc-hub

Terraform module to create a multi-tiered, multi-AZ VPC for use with Transit Gateway.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14.2 |
| aws | >= 3.20.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.20.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_availability_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) |
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) |
| [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) |
| [aws_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) |
| [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) |
| [aws_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) |
| [aws_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) |
| [aws_network_acl_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) |
| [aws_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) |
| [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) |
| [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| gateway | Type of gateway to use for environment (`transit-gateway`, `nat`, `none`) | `string` | `"none"` | no |
| tags\_common | Ministry of Justice required tags | `map(any)` | n/a | yes |
| tags\_prefix | Prefix for name tags, e.g. "live\_data" | `string` | n/a | yes |
| vpc\_cidr | CIDR range for the VPC | `string` | n/a | yes |
| vpc\_flow\_log\_iam\_role | VPC Flow Log IAM role ARN for VPC Flow Logs to CloudWatch | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| non\_tgw\_subnet\_ids | Non-Transit Gateway subnet IDs (public, private, data) |
| private\_route\_tables | Private route table keys and IDs |
| public\_igw\_route | Public Internet Gateway route |
| public\_route\_tables | Public route tables |
| tgw\_subnet\_ids | Transit Gateway subnet IDs |
| vpc\_id | VPC ID |

# Share the subnets with the right places, depending on terraform workspace
resource "aws_ram_resource_share" "default" {
  for_each = local.vpcs[terraform.workspace]

  name = "${terraform.workspace}-to-${replace(each.key, "-vpc-production", "")}" # tofix: naming
  allow_external_principals = false

  tags = {
    Name = "${terraform.workspace}-to-${replace(each.key, "-vpc-production", "")}" # tofix: naming
  }
}

resource "aws_ram_resource_association" "default" {
  # Tofix: use Terraform workspace to get the right module output. When you switch workspace, you'll want to manually change these (for now)
  for_each = toset(module.vpc["hmpps-vpc-non-live-data"].non_tgw_subnet_ids)

  depends_on = [module.vpc]

  resource_arn = each.value

  resource_share_arn = aws_ram_resource_share.default["hmpps-vpc-non-live-data"].arn
}

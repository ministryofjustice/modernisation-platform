# lookups for DNS

data "aws_route53_zone" "public" {
  provider = aws.core-network-services

  name         = local.modernisation-platform-domain
  private_zone = false
}

data "aws_route53_zone" "private" {
  provider = aws.core-network-services

  name         = local.modernisation-platform-internal-domain
  private_zone = true
}

# lookups for routing

data "aws_vpc" "selected" {
  provider = aws.core-network-services

  filter {
    name   = "tag:Name"
    values = [local.type]
  }
}

data "aws_route_table" "main-public" {
  provider = aws.core-network-services

  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Name"
    values = ["${local.type}-public"]
  }
}

locals {

  type = local.is-live_data ? "live_data" : "non_live_data"

  # Get all VPC definitions by type
  vpcs = {
    # VPCs that sit within the core-vpc-production account
    core-vpc-production = {
      for file in fileset("../../../environments-networks", "*-production.json") :
      replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
    }

    core-vpc-preproduction = {
      for file in fileset("../../../environments-networks", "*-preproduction.json") :
      replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
    }

    # VPCs that sit within the core vpc test account
    core-vpc-test = {
      for file in fileset("../../../environments-networks", "*-test.json") :
      replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
    }

    # VPCs that sit within the core vpc development account
    core-vpc-development = {
      for file in fileset("../../../environments-networks", "*-development.json") :
      replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
    }

  }

  account_numbers = flatten([
    for dept, data in local.vpcs[terraform.workspace] : {
      key = dept
      account_nos = flatten([
        for subnet_set in data.cidr.subnet_sets : [
          for account in subnet_set.accounts :
          local.environment_management.account_ids[account]
        ]
      ])
    }
  ])

  expanded_account_numbers_with_keys = {
    for data in local.account_numbers :
    data.key => data.account_nos
  }

  non-tgw-vpc-subnet = flatten([
    for key, vpc in module.vpc : [
      for set in keys(module.vpc[key].non_tgw_subnet_arns_by_subnetset) : {
        key  = key
        set  = set
        arns = module.vpc[key].non_tgw_subnet_arns_by_subnetset[set]
      }
    ]
  ])

  modernisation-platform-domain          = "modernisation-platform.service.justice.gov.uk"
  modernisation-platform-internal-domain = "modernisation-platform.internal"
}

module "vpc" {
  for_each = local.vpcs[terraform.workspace]

  source = "../../modules/member-vpc"

  subnet_sets = { for key, subnet in each.value.cidr.subnet_sets : key => subnet.cidr }
  protected   = each.value.cidr.protected
  transit     = each.value.cidr.transit_gateway


  additional_endpoints = each.value.options.additional_endpoints
  bastion_linux        = each.value.options.bastion_linux
  #bastion_windows = each.value.options.bastion_windows

  transit_gateway_id = data.aws_ec2_transit_gateway.transit-gateway.id

  # VPC Flow Logs
  vpc_flow_log_iam_role = data.aws_iam_role.vpc-flow-log.arn

  # # CIDRs
  # subnet_cidrs_by_type = each.value.cidr.subnets
  # vpc_cidr             = each.value.cidr.vpc

  # # NACL rules
  # nacl_ingress = each.value.nacl.ingress
  # nacl_egress  = each.value.nacl.egress

  # # NAT Gateway
  # enable_nat_gateway = false

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}

module "vpc_tgw_routing" {
  source = "../../modules/vpc-tgw-routing"

  for_each = local.vpcs[terraform.workspace]

  providers = {
    aws = aws.core-network-services
  }

  route_table        = data.aws_route_table.main-public
  subnet_sets        = { for key, subnet in each.value.cidr.subnet_sets : key => subnet.cidr }
  tgw_vpc_attachment = module.vpc_attachment[each.key].tgw_vpc_attachment
  tgw_route_table    = module.vpc_attachment[each.key].tgw_route_table
  tgw_id             = data.aws_ec2_transit_gateway.transit-gateway.id

  depends_on = [module.vpc_attachment, module.vpc]
}

module "vpc_nacls" {
  source                 = "../../modules/vpc-nacls"
  for_each               = local.vpcs[terraform.workspace]
  nacl_config            = each.value.nacl
  nacl_refs              = module.vpc[each.key].nacl_refs
  cidrs_for_s3_endpoints = module.vpc[each.key].data_network_acl_for_endpoints
  tags_prefix            = each.key
}

locals {
  non-tgw-vpc = flatten([
    for key, vpc in module.vpc : [
      for set in keys(module.vpc[key].non_tgw_subnet_arns_by_set) : {
        key  = key
        set  = set
        arns = module.vpc[key].non_tgw_subnet_arns_by_set[set]
      }
    ]
  ])
}

module "resource-share" {
  source = "../../modules/ram-resource-share"
  for_each = {
    for vpc in local.non-tgw-vpc-subnet : "${vpc.key}-${vpc.set}" => vpc
  }

  # Subnet ARNs to attach to a resource share
  resource_arns = [for key, subnet in each.value.arns : subnet]

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}

module "core-vpc-tgw-routes" {
  for_each = local.vpcs[terraform.workspace]
  source   = "../../modules/core-vpc-tgw-routes"

  transit_gateway_id = data.aws_ec2_transit_gateway.transit-gateway.id
  route_table_ids    = module.vpc[each.key].private_route_tables

  depends_on = [module.vpc_attachment]
}

module "dns-zone" {
  depends_on = [module.vpc]

  providers = {
    aws.core-network-services = aws.core-network-services
  }

  for_each = local.vpcs[terraform.workspace]
  source   = "../../modules/dns-zone"

  dns_zone                       = each.key
  vpc_id                         = module.vpc[each.key].vpc_id
  public_dns_zone                = data.aws_route53_zone.public
  private_dns_zone               = data.aws_route53_zone.private
  accounts                       = { for key, account in each.value.cidr.subnet_sets : key => account.accounts }
  modernisation_platform_account = data.aws_caller_identity.modernisation-platform.account_id
  environments                   = local.environment_management

  # Tags
  tags_common = local.tags
  tags_prefix = each.key

}

module "dns_zone_extend" {

  for_each = local.vpcs[terraform.workspace]

  source = "../../modules/dns-zone-extend"

  environment = trimprefix(terraform.workspace, "${var.networking[0].application}-")
  zone_id     = { for key, zone in each.value.options.dns_zone_extend : key => zone }
  vpc_id      = module.vpc[each.key].vpc_id
  dns_domain  = ".modernisation-platform.internal"
}

resource "aws_iam_role" "member-delegation" {
  for_each = local.vpcs[terraform.workspace]

  name = "member-delegation-${each.key}"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : concat(
              local.expanded_account_numbers_with_keys[each.key],
              tolist([data.aws_caller_identity.modernisation-platform.account_id])
            )
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {}
        }
      ]
  })

  tags = merge(
    local.tags,
    {
      Name = "${each.key}-member-delegation-role"
    },
  )
}

resource "aws_iam_role_policy" "member-delegation" {
  for_each = local.vpcs[terraform.workspace]

  name = "member-delegation-${each.key}"
  role = aws_iam_role.member-delegation[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:List*",
          "route53:Get*",
          "route53resolver:CreateResolverEndpoint",
          "route53resolver:ListResolverEndpoints",
          "route53resolver:GetResolverEndpoint",
          "route53resolver:ListResolverEndpointIpAddresses",
          "route53resolver:CreateResolverRule",
          "route53resolver:GetResolverRule",
          "route53resolver:AssociateResolverRule",
          "route53resolver:GetResolverRuleAssociation",
          "route53resolver:UpdateResolverRule",
          "ec2:DescribeSubnets",
          "route53resolver:ListTagsForResource",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeVpcs",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DescribeSecurityGroupReferences",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:ModifySecurityGroupRules",
          "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribePrefixLists"
        ],
        "Resource" : "*"
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:CreateTrafficPolicy",
          "route53:DeleteTrafficPolicy",
          "route53:CreateTrafficPolicyInstance",
          "route53:CreateTrafficPolicyVersion",
          "route53:UpdateTrafficPolicyInstance",
          "route53:UpdateTrafficPolicyComment",
          "route53:DeleteTrafficPolicyInstance",
          "route53:CreateHealthCheck",
          "route53:UpdateHealthCheck",
          "route53:DeleteHealthCheck"
        ],
        Resource = [
          "arn:aws:route53:::hostedzone/${module.dns-zone[each.key].zone_public}",
          "arn:aws:route53:::hostedzone/${module.dns-zone[each.key].zone_private}"
        ]
      },
    ]
  })
}

# Read only role for developer sso plans
resource "aws_iam_role" "member_delegation_read_only" {
  name = "member-delegation-read-only"
  assume_role_policy = jsonencode( # checkov:skip=CKV_AWS_60: "the policy is secured with the condition"
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {
            "ForAnyValue:StringLike" : {
              "aws:PrincipalOrgPaths" : ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
            }
          }
        }
      ]
  })

  tags = merge(
    local.tags,
    {
      Name = "member-delegation-read-only"
    },
  )
}

resource "aws_iam_role_policy" "member_delegation_read_only" {
  name = "MemberDelegationReadOnly"
  role = aws_iam_role.member_delegation_read_only.name

  policy = jsonencode({ #tfsec:ignore:AWS099 - we need to be able to read across all hosted zones to have this as a generic role
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:List*",
          "route53:Get*",
          "ec2:DescribeSecurityGroupReferences",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribePrefixLists"
        ],
        "Resource" : "*"
      },
    ]
  })
}

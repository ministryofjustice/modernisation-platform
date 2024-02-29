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

    # VPCs that sit within the core vpc sandbox account
    core-vpc-sandbox = {
      for file in fileset("../../../environments-networks", "*-sandbox.json") :
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

  source = "github.com/ministryofjustice/modernisation-platform-terraform-member-vpc?ref=93ecac996b01626cd262a13f4972b520b33d05ee" # See branch add-aws-firehose

  subnet_sets = { for key, subnet in each.value.cidr.subnet_sets : key => subnet.cidr }

  additional_endpoints = each.value.options.additional_endpoints

  transit_gateway_id = data.aws_ec2_transit_gateway.transit-gateway.id

  # VPC Flow Logs
  vpc_flow_log_iam_role = data.aws_iam_role.vpc-flow-log.arn

  # Variables required for Firehose integration

  secret_string = tostring(local.firehose_preprod_network_secret["xsiam_preprod_network_secret"])

  endpoint_url = local.endpoint_url

  environment = substr(terraform.workspace, length(local.application_name) + 1, length(terraform.workspace))

  # build_firehose = anytrue([local.is-development, local.is-production]) 

  build_firehose = (local.is-development == true && each.key == "hmpps-development")
  
  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}

module "vpc_nacls" {
  source           = "../../modules/vpc-nacls"
  for_each         = local.vpcs[terraform.workspace]
  additional_cidrs = each.value.options.additional_cidrs
  additional_vpcs  = each.value.options.additional_vpcs
  tags             = local.tags
  tags_prefix      = each.key
  vpc_name         = each.key
}

module "route_53_resolver_logs" {
  source      = "../../modules/r53-resolver-logs"
  for_each    = { for key, value in module.vpc : key => value["vpc_id"] }
  tags_common = local.tags
  vpc_id      = each.value
  vpc_name    = each.key
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

module "dns-zone" {
  depends_on = [
    module.vpc
  ]

  providers = {
    aws.core-network-services = aws.core-network-services
    aws.aws-us-east-1         = aws.aws-us-east-1
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
  monitoring_sns_topic           = aws_sns_topic.route53_monitoring.arn

  # Tags
  tags_common = local.tags
  tags_prefix = each.key

}

module "dns_zone_extend" {
  depends_on = [
    module.dns-zone
  ]

  for_each = local.vpcs[terraform.workspace]

  source = "../../modules/dns-zone-extend"

  environment = trimprefix(terraform.workspace, "${var.networking[0].application}-")
  zone_id     = { for key, zone in each.value.options.dns_zone_extend : key => zone }
  vpc_id      = module.vpc[each.key].vpc_id
  dns_domain  = ".modernisation-platform.internal"
}

module "dns_zone_extend_private" {
  source = "../../modules/dns-zone-extend-private"
  providers = {
    aws.core-network-services = aws.core-network-services
    aws.core-vpc              = aws
  }

  for_each  = local.vpcs[terraform.workspace]
  zone_name = { for key, zone in each.value.options.additional_private_zones : key => zone }
  vpc_id    = module.vpc[each.key].vpc_id
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
  # checkov:skip=CKV_AWS_355: This create and manage on multiple resources which have not yet been defined
  # checkov:skip=CKV_AWS_290: This create and manage on multiple resources which have not yet been defined
  # checkov:skip=CKV_AWS_289: This create and manage on multiple resources which have not yet been defined
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
          "route53resolver:DeleteResolverEndpoint",
          "route53resolver:ListResolverEndpoints",
          "route53resolver:GetResolverEndpoint",
          "route53resolver:ListResolverEndpointIpAddresses",
          "route53resolver:CreateResolverRule",
          "route53resolver:DeleteResolverRule",
          "route53resolver:DisassociateResolverRule",
          "route53resolver:GetResolverRule",
          "route53resolver:AssociateResolverRule",
          "route53resolver:GetResolverRuleAssociation",
          "route53resolver:UpdateResolverRule",
          "route53resolver:TagResource",
          "ec2:DescribeSubnets",
          "route53resolver:ListTagsForResource",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeVpcs",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:CreateTags",
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
          "ec2:DescribePrefixLists",
          "ec2:CreateSubnetCidrReservation",
          "ec2:DeleteSubnetCidrReservation",
          "ec2:GetSubnetCidrReservations"
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
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:*:*:log-group::log-stream:",
          "arn:aws:logs:*:*:log-group:*-vpc-flow-logs-*:log-stream:*",
        ],
      },
    ]
  })
}

# Read only role for developer sso plans and for viewing via the console
resource "aws_iam_role" "member_delegation_read_only" {
  name                = "member-delegation-read-only"
  managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
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

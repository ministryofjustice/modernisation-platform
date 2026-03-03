# VPC Flow Log: configure an IAM role
resource "aws_iam_role" "vpc_flow_log" {
  name               = "AWSVPCFlowLog"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_assume_role_policy.json
}

# VPC Flow Log: assume role policy
data "aws_iam_policy_document" "vpc_flow_log_assume_role_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

# VPC Flow Log: publish to CloudWatch
resource "aws_iam_policy" "vpc_flow_log_publish_policy" {
  name   = "AWSVPCFlowLogPublishPolicy"
  policy = data.aws_iam_policy_document.vpc_flow_log_publish_policy.json
}

# Extrapolated from:
# https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html
# tfsec ignore appropriate as wildcard in line with AWS published guidance
# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "vpc_flow_log_publish_policy" {

  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints - This is limited to the log actions only"
  #checkov:skip=CKV_AWS_356: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions - This is limited to the log actions only"
  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"

  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_publish_policy" {
  role       = aws_iam_role.vpc_flow_log.id
  policy_arn = aws_iam_policy.vpc_flow_log_publish_policy.arn
}

# Role to allow ci/cd to update DNS records for ACM certificate validation
resource "aws_iam_role" "dns" {
  #checkov:skip=CKV_AWS_60:Wildcard constrained by condition checks
  name = "modify-dns-records"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : data.aws_caller_identity.modernisation-platform.account_id
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {}
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${local.environment_management.account_ids["testing-test"]}:user/testing-ci"
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {}
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {
            "ForAnyValue:StringLike" : {
              "aws:PrincipalOrgPaths" : ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"],
              "aws:PrincipalArn" : ["arn:aws:iam::*:role/github-actions", "arn:aws:iam::*:role/github-actions-environments-read-only", "arn:aws:iam::*:role/github-actions-environments-dev-test", "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_AdministratorAccess_*"]
            }
          }
        }
      ]
  })

  tags = merge(
    local.tags,
    {
      Name = "modify-dns-records"
    },
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "dns" {
  name = "modify-dns-records"
  role = aws_iam_role.dns.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:Get*",
          "route53:List*"
        ],
        "Resource" : "*"
      },
      {
        Effect = "Allow",
        Action = ["route53:ChangeResourceRecordSets"],
        Resource = concat(
          [for zone in aws_route53_zone.application_zones : format("arn:aws:route53:::hostedzone/%s", zone.id)],
          [for zone in aws_route53_zone.private_application_zones : format("arn:aws:route53:::hostedzone/%s", zone.id)],
          [
            "arn:aws:route53:::hostedzone/${aws_route53_zone.modernisation-platform.id}",
            "arn:aws:route53:::hostedzone/${aws_route53_zone.modernisation-platform-internal.id}"

          ]
        )
      }
    ]
  })
}

# Role to allow developer SSO user to read DNS records for ACM certificate validation for local plan
resource "aws_iam_role" "read_logs" {
  name = "read-log-records"
  assume_role_policy = jsonencode(
    # checkov:skip=CKV_AWS_60: "the policy is secured with the condition"
    # checkov:skip=CKV_AWS_355: "the policy is secured with the condition"
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
      Name = "read-log-records"
    },
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "read_dns" {
  # checkov:skip=CKV_AWS_355: "the policy is secured with the condition"
  name = "ReadDNSRecords"
  role = aws_iam_role.read_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:Get*",
          "route53:List*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeVpnConnections",
          "ec2:DescribeVpnGateways",
          "ec2:DescribeCustomerGateways",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeTransitGatewayAttachments",
          "ec2:DescribeTransitGatewayRouteTables",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeAddresses", # Elastic IPs
          "ec2:DescribeNetworkInterfaces",
          "ec2:GetTransitGatewayRouteTablePropagations",
          "ec2:GetTransitGatewayRouteTableAssociations",
          "ec2:GetTransitGatewayPrefixListReferences",
          "ec2:SearchTransitGatewayRoutes"
        ],
        "Resource" : "*"
      }
    ]
  })
}


#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "read_firewall" {
  # checkov:skip=CKV_AWS_355: "the policy is secured with the condition"
  name = "ReadFirewallRecords"
  role = aws_iam_role.read_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:DescribeQueries",
          "logs:FilterLogEvents",
          "logs:GetLogEvents",
          "logs:GetLogGroupFields",
          "logs:GetLogRecord",
          "logs:GetQueryResults",
          "logs:StartQuery",
          "logs:StopQuery"
        ],
        "Resource" : [
          "arn:aws:logs:*:*:log-group::log-stream:",
          "arn:aws:logs:*:*:log-group:fw-*:log-stream:*",
          "arn:aws:logs:*:*:log-group:*-vpc-flow-logs-*:log-stream:*",
          "arn:aws:logs:*:*:log-group:external-inspection-flow-logs:log-stream:*",
          "arn:aws:logs:*:*:log-group:tgw-*:log-stream:*",
          "arn:aws:logs:*:*:log-group:NEC*:log-stream:*"
        ],
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "network-firewall:Describe*",
          "network-firewall:List*"
        ],
        "Resource" : "arn:aws:network-firewall:*:*:*/*"
      }
    ]
  })
}

# GitHub OIDC Role assumed by GitHub Actions workflows to perform VPN maintenance tasks

module "vpn_environment_check_oidc" {
  source                      = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=6dd6f177091fb1664998aa37a1d0d5cf5894c10a" # v4.2.0
  role_name                   = "github-actions-vpn-environment-check"
  create_github_oidc_provider = false
  github_repositories         = ["ministryofjustice/modernisation-platform-environments:*"]
  additional_permissions      = data.aws_iam_policy_document.vpn_environment_check_permissions.json
  tags_common                 = { "Name" = format("%s-oidc", terraform.workspace) }
  tags_prefix                 = ""
}

data "aws_iam_policy_document" "vpn_environment_check_permissions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeVpnConnections"
    ]
    resources = local.vpn_lifecycle_control_arns
  }
}
module "vpn_maintenance_oidc" {
  source                      = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=6dd6f177091fb1664998aa37a1d0d5cf5894c10a" # v4.2.0
  role_name                   = "github-actions-vpn-maintenance"
  create_github_oidc_provider = false
  github_repositories         = local.github_repository_environments_from_vpns
  additional_permissions      = data.aws_iam_policy_document.vpn_maintenance_permissions.json
  tags_common                 = { "Name" = format("%s-oidc", terraform.workspace) }
  tags_prefix                 = ""
}

data "aws_iam_policy_document" "vpn_maintenance_permissions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeVpnConnections",
      "ec2:ReplaceVpnTunnel"
    ]
    resources = local.vpn_lifecycle_control_arns
  }
}
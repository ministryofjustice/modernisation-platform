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

data "aws_route53_zone" "private-zones" {
  for_each     = local.private-application-zones
  name         = each.value
  private_zone = true
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
              "aws:PrincipalArn" : ["arn:aws:iam::*:role/github-actions", "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_AdministratorAccess_*"]
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
          [for zone in data.aws_route53_zone.private-zones : format("arn:aws:route53:::hostedzone/%s", zone.id)],
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
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:Get*",
          "route53:List*"
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
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:*:*:log-group::log-stream:",
          "arn:aws:logs:*:*:log-group:fw-*:log-stream:*",
          "arn:aws:logs:*:*:log-group:*-vpc-flow-logs-*:log-stream:*",
          "arn:aws:logs:*:*:log-group:external-inspection-flow-logs:log-stream:*",
          "arn:aws:logs:*:*:log-group:tgw-*:log-stream:*"
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
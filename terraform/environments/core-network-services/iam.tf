data "aws_iam_role" "vpc-flow-log" {
  name = "AWSVPCFlowLog"
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
          [
            "arn:aws:route53:::hostedzone/${aws_route53_zone.modernisation-platform.id}",
            "arn:aws:route53:::hostedzone/${aws_route53_zone.modernisation-platform-internal.id}",
            "arn:aws:route53:::hostedzone/${data.aws_route53_zone.selected.zone_id}"
          ]
        )
      }
    ]
  })
}

# Role to allow developer SSO user to read DNS records for ACM certificate validation for local plan
resource "aws_iam_role" "read_dns" {
  name = "read-dns-records"
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
      Name = "read-dns-records"
    },
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "read_dns" {
  # checkov:skip=CKV_AWS_355: "the policy is secured with the condition"
  name = "ReadDNSRecords"
  role = aws_iam_role.read_dns.id

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

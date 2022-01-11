data "aws_iam_role" "vpc-flow-log" {
  name = "AWSVPCFlowLog"
}

# Role to allow ci/cd to update DNS records for ACM certificate validation
resource "aws_iam_role" "dns" {
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
        Resource = [
          "arn:aws:route53:::hostedzone/${aws_route53_zone.modernisation-platform.id}",
          "arn:aws:route53:::hostedzone/${aws_route53_zone.modernisation-platform-internal.id}"
        ]
      }
    ]
  })
}

# Role to allow developer SSO user to read DNS records for ACM certificate validation for local plan
resource "aws_iam_role" "read_dns" {
  name = "read-dns-records"
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
      Name = "read-dns-records"
    },
  )
}

resource "aws_iam_role_policy" "read_dns" {
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
        Resource = [
          "arn:aws:route53:::hostedzone/${aws_route53_zone.modernisation-platform.id}",
          "arn:aws:route53:::hostedzone/${aws_route53_zone.modernisation-platform-internal.id}"
      ] }
    ]
  })
}

#read only role for health check
module "iam_assumable_roles" {
  source               = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles"
  version              = "~> 2.0"
  max_session_duration = 43200

  # Read-only role
  create_readonly_role       = true
  readonly_role_name         = "readonly"
  readonly_role_requires_mfa = true

  # Allow created users to assume these roles
  trusted_role_arns = [
    data.aws_caller_identity.modernisation-platform.account_id
  ]
}

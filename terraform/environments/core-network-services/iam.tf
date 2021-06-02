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

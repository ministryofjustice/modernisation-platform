resource "aws_iam_role" "circleci_iam_role" {
  name = "circleci_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity",
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.circleci_oidc_provider.arn
      },
      Condition = {
        StringLike = {
          "${aws_iam_openid_connect_provider.circleci_oidc_provider.url}:sub" = "org/${local.secret_json.organisation_id}/*"
        }
      }
    }]
  })
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "circleci_iam_policy" {
  #checkov:skip=CKV_AWS_356:
  #checkov:skip=CKV_AWS_108: 
  #checkov:skip=CKV_AWS_109:
  #checkov:skip=CKV_AWS_110: 
  #checkov:skip=CKV_AWS_111
  statement {
    actions = [
				"s3:ListBucket",
				"s3:*",
				"dms:*",
				"glue:*",
				"rds:*",
				"logs:PutLogEvents",
				"logs:CreateLogStream",
				"logs:CreateLogGroup",
				"logs:PutRetentionPolicy",
				"logs:Delete*",
				"logs:Describe*",
				"logs:List*",
				"logs:Tag*",
				"logs:Untag*",
				"lambda:*",
				"kms:GenerateDataKey",
				"kms:Decrypt*",
				"iam:PassRole",
				"elasticbeanstalk:*",
				"elasticache:*",
				"ecs:*",
				"ec2:TerminateInstances",
				"ec2:RunInstances",
				"ec2:Describe*",
				"ec2:CreateTags",
				"ec2:DescribeVpcs",
				"ec2:CreateSecurityGroup",
				"ec2:RevokeSecurityGroupEgress",
				"ec2:DeleteSecurityGroup",
				"cloudformation:*",
				"secretsmanager:*",
				"iam:*",
				"ec2:AuthorizeSecurityGroupIngress",
				"ec2:AuthorizeSecurityGroupEgress",
				"events:Put*",
				"events:Delete*",
				"events:Describe*",
				"events:List*",
				"kms:*",
				"states:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "circleci_iam_policy" {
  name        = "circleci_iam_policy"
  description = "Policy for CircleCI"
  policy      = data.aws_iam_policy_document.circleci_iam_policy.json
}


resource "aws_iam_policy_attachment" "circleci_policy_attachment" {
  policy_arn = aws_iam_policy.circleci_iam_policy.arn
  roles      = [aws_iam_role.circleci_iam_role.name]
  name       = "circleci_policy_attachment"
}

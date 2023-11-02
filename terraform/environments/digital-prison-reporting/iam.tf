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


data "aws_iam_policy_document" "circleci_iam_policy" {
  statement {
    actions = [
      "ec2:RunInstances",
      "ec2:DescribeInstances",
      "ec2:TerminateInstances",
      "ec2:CreateTags",
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "iam:PassRole",
      "elasticbeanstalk:*",
      "rds:*",
      "lambda:*",
      "cloudformation:*",
      "ecs:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "elasticache:*",
      "kms:Decrypt*",
      "kms:GenerateDataKey"
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
resource "aws_iam_user" "cicd_member_user" {
  name = "cicd-member-user"
}

resource "aws_iam_group" "cicd_member_group" {
  name = "cicd-member-group"
}

resource "aws_iam_policy" "policy" {
  name        = "cicd-member-policy"
  description = "IAM Policy for CICD member user"
  policy = jsonencode({ #tfsec:ignore:AWS099
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "iam:PassRole"

        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "aws_config_attach" {
  group      = aws_iam_group.cicd_member_group.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_group_membership" "cicd-member" {
  name = "cicd-member-group-membership"

  users = [
    aws_iam_user.cicd_member_user.name
  ]

  group = aws_iam_group.cicd_member_group.name
}
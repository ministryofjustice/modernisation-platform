# Create the CICD user in the member account which is used for application deployments
resource "aws_iam_user" "cicd_member_user" {
  name = "cicd-member-user"
}

#tfsec:ignore:aws-iam-enforce-mfa
resource "aws_iam_group" "cicd_member_group" {
  name = "cicd-member-group"
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "policy" {
  name        = "cicd-member-policy"
  description = "IAM Policy for CICD member user"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codebuild:Start*",
          "codepipeline:StartPipelineExecution",
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
          "iam:PassRole",
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "s3:ListBucket",
          "s3:*Object*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "aws_cicd_member_attach" {
  group      = aws_iam_group.cicd_member_group.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_group_policy_attachment" "aws_ec2_readonly_attach" {
  group      = aws_iam_group.cicd_member_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_group_membership" "cicd-member" {
  name = "cicd-member-group-membership"

  users = [
    aws_iam_user.cicd_member_user.name
  ]

  group = aws_iam_group.cicd_member_group.name
}

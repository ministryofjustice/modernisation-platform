# Create the CICD user in the member account which is used for application deployments
resource "aws_iam_user" "cicd_member_user" {
  #checkov:skip=CKV_AWS_273: "Skipping as tfsec check is also ignored"
  name = "cicd-member-user"
}

#tfsec:ignore:aws-iam-enforce-mfa
resource "aws_iam_group" "cicd_member_group" {
  name = "cicd-member-group"
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "policy" {
  #checkov:skip=CKV_AWS_289
  #checkov:skip=CKV_AWS_288
  #checkov:skip=CKV_AWS_290
  name        = "cicd-member-policy"
  description = "IAM Policy for CICD member user"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "secretsmanager:DescribeSecret",
          "s3:*Object*",
          "ecs:StartTask",
          "s3:ListBucket",
          "ecr:UploadLayerPart",
          "ecs:DescribeTaskDefinition",
          "ecs:ListServices",
          "ecs:UpdateService",
          "iam:PassRole",
          "ecs:CreateService",
          "ecs:RunTask",
          "codebuild:Start*",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecr:CompleteLayerUpload",
          "kms:DescribeKey",
          "ecs:StopTask",
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecr:BatchCheckLayerAvailability",
          "ecs:ListTaskDefinitions",
          "ecs:UpdateTaskSet",
          "ecs:CreateTaskSet",
          "codepipeline:StartPipelineExecution",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
          "ecr:PutImage",
          "secretsmanager:GetResourcePolicy",
          "ecr:BatchGetImage",
          "kms:GenerateDataKey",
          "ecr:InitiateLayerUpload",
          "secretsmanager:ListSecrets",
          "iam:getRole",
          "iam:listRolePolicies"
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

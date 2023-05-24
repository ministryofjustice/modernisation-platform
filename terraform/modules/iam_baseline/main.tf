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
  #checkov:skip=CKV_AWS_355: Allows access to multiple unknown resources
  name        = "cicd-member-policy"
  description = "IAM Policy for CICD member user"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "codebuild:Start*",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codepipeline:StartPipelineExecution",
          "dms:StartReplicationTask",
          "dms:StopReplicationTask",
          "dms:TestConnection",
          "dms:StartReplicationTaskAssessment",
          "dms:StartReplicationTaskAssessmentRun",
          "dms:DescribeEndpoints",
          "dms:DescribeEndpointSettings",
          "dms:RebootReplicationInstance",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:deregisterTaskDefinition",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTasks",
          "ecs:StartTask",
          "ecs:ListServices",
          "ecs:CreateService",
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:ListTaskDefinitions",
          "ecs:UpdateTaskSet",
          "ecs:CreateTaskSet",
          "ecs:StopTask",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "elasticfilesystem:DescribeFileSystems",
          "glue:GetJobRuns",
          "glue:StartJobRun",
          "glue:GetJobs",
          "glue:GetTable",
          "glue:BatchGetJobs",
          "glue:ListJobs",
          "glue:StartJobRun",
          "glue:StartTrigger",
          "glue:StopSession",
          "glue:StopTrigger",
          "glue:BatchStopJobRun",
          "glue:StopWorkflowRun",
          "glue:UpdateJob",
          "iam:getRole",
          "iam:getRolePolicy",
          "iam:listAttachedRolePolicies",
          "iam:listInstanceProfilesForRole",
          "iam:listRolePolicies",
          "iam:PassRole",
          "kinesis:PutRecord",
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "logs:GetLogEvents",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:*Object*",
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "ssm:GetParameter"
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

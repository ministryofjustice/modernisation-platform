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
          "codebuild:Start*",
          "codepipeline:StartPipelineExecution",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTasks",
          "ecs:StopTask",
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
          "s3:ListAllMyBuckets",
          "s3:*Object*",
          "secretsmanager:ListSecrets",
          "iam:getRole",
          "iam:listRolePolicies",
          "iam:getRolePolicy",
          "iam:listAttachedRolePolicies",
          "ecs:deregisterTaskDefinition",
          "iam:listInstanceProfilesForRole",
          "secretsmanager:DescribeSecret",
          "ecs:StartTask",
          "ecr:UploadLayerPart",
          "ecs:ListServices",
          "ecs:CreateService",
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:ListTaskDefinitions",
          "ecs:UpdateTaskSet",
          "ecs:CreateTaskSet",
          "secretsmanager:GetResourcePolicy",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "logs:GetLogEvents",
          # The following permissions are needed for the ServiceDiscovery and the AWS Cloud Map, see the doc: https://docs.aws.amazon.com/cloud-map/latest/dg/cloud-map-api-permissions-ref.html
          "servicediscovery:CreateHttpNamespace",
          "servicediscovery:UpdateHttpNamespace",
          "servicediscovery:DeleteNamespace",
          "servicediscovery:GetNamespace",
          "servicediscovery:ListNamespaces",
          "servicediscovery:CreatePrivateDnsNamespace",
          "servicediscovery:CreatePublicDnsNamespace",
          "servicediscovery:UpdatePrivateDnsNamespace",
          "servicediscovery:UpdatePublicDnsNamespace",
          "servicediscovery:CreateService",
          "servicediscovery:DeleteService",
          "servicediscovery:UpdateService",
          "servicediscovery:GetService",
          "servicediscovery:ListServices",
          "servicediscovery:DeregisterInstance",
          "servicediscovery:DiscoverInstances",
          "servicediscovery:RegisterInstance",
          "servicediscovery:GetInstance",
          "servicediscovery:ListInstances",
          "servicediscovery:GetInstancesHealthStatus",
          "servicediscovery:UpdateInstanceCustomHealthStatus",
          "servicediscovery:GetOperation",
          "servicediscovery:ListOperations",
          "route53:CreateHostedZone",
          "route53:GetHostedZone",
          "route53:DeleteHostedZone",
          "route53:ListHostedZonesByName",
          "route53:CreateHealthCheck",
          "route53:GetHealthCheck",
          "route53:DeleteHealthCheck",
          "route53:UpdateHealthCheck",
          "route53:ChangeResourceRecordSets",
          "ec2:DescribeInstances",
          "ec2:DescribeVpcs",
          "ec2:DescribeRegions"
          # This is the end of permissions needed for the ServiceDiscovery and the AWS Cloud Map, see the doc: https://docs.aws.amazon.com/cloud-map/latest/dg/cloud-map-api-permissions-ref.html
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

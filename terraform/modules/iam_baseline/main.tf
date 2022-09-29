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


## Fix for DEFAULT KMS Key Error, Ref: https://github.com/hashicorp/terraform-provider-aws/issues/3450
resource "aws_iam_policy" "default_kms_key_policy" {
  name        = "cicd-member-kms-policy"
  description = "IAM Policy for Default KMS Key, CICD member user"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:kms:eu-west-2:771283872747:key/16234827-4f3c-479e-8000-7a3e75c6ed7e"
      },
    ]
  })
}

## Fix for DEFAULT KMS Key Error, Ref: https://github.com/hashicorp/terraform-provider-aws/issues/3450
resource "aws_iam_group_policy_attachment" "aws_cicd_member_attach" {
  group      = aws_iam_group.cicd_member_group.name
  policy_arn = aws_iam_policy.default_kms_key_policy.arn
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
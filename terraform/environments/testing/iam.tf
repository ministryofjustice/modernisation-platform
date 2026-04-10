# OIDC Resources for testing-test account

module "github-oidc" {
  source                 = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=5dc9bc211d10c58de4247fa751c318a3985fc87b" # v4.0.0
  additional_permissions = data.aws_iam_policy_document.oidc_deny_specific_actions.json
  github_repositories = [
    "ministryofjustice/modernisation-platform-github-oidc-provider:*",
    "ministryofjustice/modernisation-platform-github-oidc-role:*",
    "ministryofjustice/modernisation-platform-terraform-aws-chatbot:*",
    "ministryofjustice/modernisation-platform-terraform-aws-data-firehose:*",
    "ministryofjustice/modernisation-platform-terraform-aws-vm-import:*",
    "ministryofjustice/modernisation-platform-terraform-aws-waf:*",
    "ministryofjustice/modernisation-platform-terraform-baselines:*",
    "ministryofjustice/modernisation-platform-terraform-bastion-linux:*",
    "ministryofjustice/modernisation-platform-terraform-certificate-dns-validations:*",
    "ministryofjustice/modernisation-platform-terraform-cross-account-access:*",
    "ministryofjustice/modernisation-platform-terraform-dns-certificates:*",
    "ministryofjustice/modernisation-platform-terraform-ec2-autoscaling-group:*",
    "ministryofjustice/modernisation-platform-terraform-ec2-instance:*",
    "ministryofjustice/modernisation-platform-terraform-ecs-cluster:*",
    "ministryofjustice/modernisation-platform-terraform-environments:*",
    "ministryofjustice/modernisation-platform-terraform-iam-superadmins:*",
    "ministryofjustice/modernisation-platform-terraform-lambda-function:*",
    "ministryofjustice/modernisation-platform-terraform-loadbalancer:*",
    "ministryofjustice/modernisation-platform-terraform-member-vpc:*",
    "ministryofjustice/modernisation-platform-terraform-module-template:*",
    "ministryofjustice/modernisation-platform-terraform-pagerduty-integration:*",
    "ministryofjustice/modernisation-platform-terraform-s3-bucket:*",
    "ministryofjustice/modernisation-platform-terraform-ssm-patching:*"
  ]
  tags_common = { "Name" = format("%s-oidc", terraform.workspace) }
  tags_prefix = ""
}

data "aws_iam_policy_document" "oidc_deny_specific_actions" {
  statement {
    effect = "Deny"
    actions = [
      "iam:ChangePassword",
      "iam:CreateLoginProfile"
    ]
    resources = ["*"]
  }
}

module "github_actions_testing_role" {
  source = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = [
    "ministryofjustice/modernisation-platform-github-oidc-provider",
    "ministryofjustice/modernisation-platform-github-oidc-role",
    "ministryofjustice/modernisation-platform-terraform-aws-chatbot",
    "ministryofjustice/modernisation-platform-terraform-aws-data-firehose",
    "ministryofjustice/modernisation-platform-terraform-aws-vm-import",
    "ministryofjustice/modernisation-platform-terraform-aws-waf",
    "ministryofjustice/modernisation-platform-terraform-baselines",
    "ministryofjustice/modernisation-platform-terraform-bastion-linux",
    "ministryofjustice/modernisation-platform-terraform-certificate-dns-validations",
    "ministryofjustice/modernisation-platform-terraform-cross-account-access",
    "ministryofjustice/modernisation-platform-terraform-dns-certificates",
    "ministryofjustice/modernisation-platform-terraform-ec2-autoscaling-group",
    "ministryofjustice/modernisation-platform-terraform-ec2-instance",
    "ministryofjustice/modernisation-platform-terraform-ecs-cluster",
    "ministryofjustice/modernisation-platform-terraform-environments",
    "ministryofjustice/modernisation-platform-terraform-iam-superadmins",
    "ministryofjustice/modernisation-platform-terraform-lambda-function",
    "ministryofjustice/modernisation-platform-terraform-loadbalancer",
    "ministryofjustice/modernisation-platform-terraform-member-vpc",
    "ministryofjustice/modernisation-platform-terraform-module-template",
    "ministryofjustice/modernisation-platform-terraform-pagerduty-integration",
    "ministryofjustice/modernisation-platform-terraform-s3-bucket",
    "ministryofjustice/modernisation-platform-terraform-ssm-patching"
  ]
  role_name   = "github-actions-testing"
  policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  policy_jsons = [
    data.aws_iam_policy_document.github_actions_testing_role_policy.json
  ]
  subject_claim = "ref:refs/heads/*"
  tags          = { "Name" = "github-actions-testing" }
}

data "aws_iam_policy_document" "github_actions_testing_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${local.environment_management.account_ids["testing-test"]}:role/MemberInfrastructureAccess",
      "arn:aws:iam::${local.environment_management.account_ids["testing-test"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-test"]}:role/member-delegation-*-test",
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/modify-dns-records"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/*.tflock",
      "arn:aws:s3:::modernisation-platform-terraform-state/terraform.tfstate",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/members/testing/testing-test/terraform.tfstate"
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:DeleteObject"]
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/*.tflock",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/members/testing/testing-test/*.tflock"
    ]
  }

  # Based on https://docs.amazonaws.cn/en_us/AmazonS3/latest/userguide/UsingKMSEncryption.htm
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      data.aws_kms_key.s3_state_bucket_multi_region.arn,
      data.aws_kms_key.environment_management_multi_region.arn,
      data.aws_kms_key.pagerduty_multi_region.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.modernisation_platform.account_id}:secret:environment_management-??????",
      "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.modernisation_platform.account_id}:secret:pagerduty_integration_keys-??????"
    ]
  }
}

data "aws_caller_identity" "modernisation_platform" {
  provider = aws.modernisation-platform
}

data "aws_kms_key" "s3_state_bucket_multi_region" {
  provider = aws.modernisation-platform
  key_id   = "alias/s3-state-bucket-multi-region"
}

data "aws_kms_key" "environment_management_multi_region" {
  provider = aws.modernisation-platform
  key_id   = "alias/environment-management-multi-region"
}

data "aws_kms_key" "pagerduty_multi_region" {
  provider = aws.modernisation-platform
  key_id   = "alias/pagerduty-secret-multi-region"
}

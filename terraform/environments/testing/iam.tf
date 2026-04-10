# OIDC Role for testing-test account

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
      "arn:aws:kms:eu-west-2:${local.environment_management.modernisation_platform_account_id}:key/*"
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
      "arn:aws:secretsmanager:eu-west-2:${local.environment_management.modernisation_platform_account_id}:secret:environment_management-??????",
      "arn:aws:secretsmanager:eu-west-2:${local.environment_management.modernisation_platform_account_id}:secret:pagerduty_integration_keys-??????"
    ]
  }
}

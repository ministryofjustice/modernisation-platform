module "cross-account-access" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=ef80831bbc71e96733abb9ff32cc3f24bcc7e55f" #v3.0.0
  providers = {
    aws = aws.workspace
  }
  account_id = local.modernisation_platform_account.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role_name  = "ModernisationPlatformAccess"
  additional_trust_roles = concat(
    [
      "arn:aws:iam::${local.environment_management.account_ids["sprinkler-development"]}:role/github-actions"
    ],
    terraform.workspace == "testing-test" ? ["arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:user/testing-ci"] : [],
    terraform.workspace == "core-vpc-sandbox" ? [
      "arn:aws:iam::${local.environment_management.account_ids["sprinkler-development"]}:role/github-actions-dev-test",
      "arn:aws:iam::${local.environment_management.account_ids["cooker-development"]}:role/github-actions-dev-test"
    ] : []
  )
  additional_trust_statements = concat(contains(["core-network-services-production"], terraform.workspace) ? [data.aws_iam_policy_document.additional_trust_policy.json] : [], length(regexall("(development|test)$", terraform.workspace)) > 0 ? [data.aws_iam_policy_document.additional_trust_policy.json] : [])
}

data "aws_iam_policy_document" "additional_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/github-actions-dev-test"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }
  }
}
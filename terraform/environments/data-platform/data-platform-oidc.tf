module "github_actions_roles" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=4e620aa32d339dbe5fd75374e915dc9f48e30a6d" # v2.0.1
  github_repositories = local.oidc_repositories
  role_name           = "data-platform-labs-github-role"
  policy_arns         = local.oidc_default_policy_arns
  policy_jsons        = [data.aws_iam_policy.cicd_member_policy.policy]
  tags                = local.tags
}

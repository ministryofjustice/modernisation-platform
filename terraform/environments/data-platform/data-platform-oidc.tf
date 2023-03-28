module "github_actions_roles" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=v1.0.0"
  github_repositories = local.oidc_repositories
  role_name           = "data-platform-labs-github-actions"
  policy_arns         = local.oidc_default_policy_arns
  policy_jsons        = [data.aws_iam_policy.cicd_member_policy.policy]
  tags                = local.tags
}
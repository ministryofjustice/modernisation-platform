module "github_actions_roles" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = local.oidc_repositories
  role_name           = "data-platform-labs-github-role"
  policy_arns         = local.oidc_default_policy_arns
  policy_jsons        = [data.aws_iam_policy.cicd_member_policy.policy]
  tags                = local.tags
}

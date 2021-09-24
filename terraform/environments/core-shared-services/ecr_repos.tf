module "performance_hub_ecr_repo" {
  source = "../../modules/app-ecr-repo"

  app_name = "performance-hub"

  account_arns = ["arn:aws:iam::${local.environment_management.account_ids["performance-hub-development"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["performance-hub-preproduction"]}:user/cicd-member-user",
    "arn:aws:iam::${local.environment_management.account_ids["performance-hub-production"]}:user/cicd-member-user",
  data.aws_caller_identity.current.arn]

  # Tags
  tags_common = local.tags
}
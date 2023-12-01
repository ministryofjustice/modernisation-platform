# Adding information tags about resources created in the testing-test account but managed in this terraform project.
data "aws_organizations_organization" "root_account" {}
data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "whoami" {
  arn = data.aws_caller_identity.current.arn
}

data "http" "environments_file" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.testing_application_name}.json"
}
locals {
  root_account                   = data.aws_organizations_organization.root_account
  modernisation_platform_account = can(regex("superadmin|AdministratorAccess", data.aws_iam_session_context.whoami.issuer_arn)) ? data.aws_caller_identity.current : local.root_account.accounts[index(local.root_account.accounts[*].email, "aws+modernisation-platform@digital.justice.gov.uk")]
  testing_application_name = "testing"

  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  # GitHub usernames for the Modernisation Platform team maintainers
  # NB: Terraform shows a perputal difference in roles if someone is an organisation owner
  # and will attempt to change them from `maintainer` to `member`, so owners should go in here.
  maintainers = [
    "ewastempel",
    "jakemulley",
    "SteveMarshall",
    "davidkelliott",
    "connormaglynn"
  ]

  # GitHub usernames for CI users
  ci_users = [
    "modernisation-platform-ci"
  ]

  # All GitHub team maintainers
  all_maintainers = concat(local.maintainers, local.ci_users)

  # GitHub usernames for team members who don't need full AWS access
  general_members = [
    "kcbotsh",
    "SteveMarshall",
    "SimonPPledger",
    "AafAnsari"
  ]

  # GitHub usernames for engineers who need full AWS access
  engineers = [
    "davidkelliott",
    "jakemulley",
    "stevelinden",
    "markgov",
    "dms1981", # David Sibley
    "ep-93",   # Edward Proctor
    "ewastempel",
    "ASTRobinson", # Aaron Robinson
    "connormaglynn",
    "richgreen-moj" # Richard Green
  ]

  # Security engineers performing reviews on the platform or member accounts
  security = [
    "joelefejuku",
    "isaacthomasMOJ"
  ]

  # Members of the long term storage account team to acccess that account
  long-term-storage = [
    "davidkelliott"
  ]

  # All members
  all_members = concat(local.general_members, local.engineers)

  # Everyone
  everyone = concat(local.all_maintainers, local.all_members)

  environments_json = [
    for file in fileset("../../environments/", "*.json") : merge({
      name = replace(file, ".json", "")
    }, jsondecode(file("../../environments/${file}")))
  ]

  application_github_slugs = concat(
    ["all-org-members"],
    distinct(flatten([
      for application in local.environments_json : [
        for environment in application.environments : [
          for access in environment.access :
          access.github_slug
          if application.account-type == "member" && !contains(["modernisation-platform", "modernisation-platform-engineers"], access.github_slug)
        ]
      ]
    ]))
  )

  # Create a list of repositories that we want our customers to be able to contribute to
  modernisation_platform_repositories = [
    for s in data.github_repositories.modernisation-platform-repositories.names : s if startswith(s, "modernisation-platform-")
  ]

  testing_tags = merge(
    jsondecode(data.http.environments_file.response_body).tags,
  { "source-code" = "https://github.com/ministryofjustice/modernisation-platform/tree/main/terraform/github" })
}

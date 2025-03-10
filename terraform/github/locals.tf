# Adding information tags about resources created in the testing-test account but managed in this terraform project.

data "http" "environments_file" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.testing_application_name}.json"
}

data "http" "collaborators_file" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/collaborators.json"
}

# Fetch all teams in the organization
data "github_organization_teams" "all_teams" {
  summary_only = true
}

locals {
  testing_application_name = "testing"

  environment_management         = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  modernisation_platform_account = local.environment_management.modernisation_platform_account_id

  # GitHub usernames for the Modernisation Platform team maintainers
  # NB: Terraform shows a perpetual difference in roles if someone is an organisation owner
  # and will attempt to change them from `maintainer` to `member`, so owners should go in here.
  maintainers = [
    "connormaglynn",
    "davidkelliott",
    "ewastempel",
    "seanprivett",
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
    "seanprivett",
    "SimonPPledger"
  ]

  # GitHub usernames for engineers who need full AWS access
  engineers = [
    "davidkelliott",
    "markgov",
    "dms1981", # David Sibley
    "ep-93",   # Edward Proctor
    "ewastempel",
    "ASTRobinson", # Aaron Robinson
    "connormaglynn",
    "richgreen-moj",   # Richard Green
    "khatraf",         # Khatra Farah
    "sukeshreddyg",    # Sukesh Reddy Gade
    "mikereiddigital", # Mike Reid
    "Kudzai-moj"       # Kudzai Mtoko
  ]

  # Security engineers performing reviews on the platform or member accounts
  security = [
  ]

  # Members of the long term storage account team to acccess that account
  long-term-storage = [
    "davidkelliott"
  ]

  # All members
  all_members = concat(local.general_members, local.engineers)

  # Everyone
  everyone = concat(local.all_maintainers, local.all_members)

  # Collaborators
  collaborators = {
    for key in jsondecode(data.http.collaborators_file.response_body).users : key.username => key.github-username
    if key.github-username != "no-value-supplied"
  }

  environments_json = [
    for file in fileset("../../environments/", "*.json") : merge({
      name = replace(file, ".json", "")
    }, jsondecode(file("../../environments/${file}")))
  ]

  all_team_slugs = [
    for team in data.github_organization_teams.all_teams.teams : team.slug
  ]

  application_github_group_names = concat( # intentional rename: this is only applicable to Github teams
    ["all-org-members"],
    distinct(flatten([
      for application in local.environments_json : [
        for environment in application.environments : [
          for access in environment.access :
          access.sso_group_name
          if application.account-type == "member" && !contains(["modernisation-platform", "modernisation-platform-engineers"], access.sso_group_name) &&
          contains(local.all_team_slugs, access.sso_group_name) # Filter out invalid Github teams (ex. azure-aws-sso-*)
        ]
      ]
    ]))
  )

  # Create a list of repositories that we want our customers to be able to contribute to
  modernisation_platform_repositories = [
    for s in data.github_repositories.modernisation-platform-repositories.names : s if startswith(s, "modernisation-platform-")
  ]

  map_permissions_to_repositories = {
    for repo in local.modernisation_platform_repositories : repo => {
      teams = merge(
        { "modernisation-platform" = "admin" },
        { "all-org-members" = "write" },
      repo == "modernisation-platform-environments" ? { for team in local.application_github_group_names : team => "write" } : null),
      users = repo == "modernisation-platform-environments" ? { for user in local.collaborators : user => "push" } : {}
    }
  }

  testing_tags = merge(
    jsondecode(data.http.environments_file.response_body).tags,
  { "source-code" = "https://github.com/ministryofjustice/modernisation-platform/tree/main/terraform/github" })
}

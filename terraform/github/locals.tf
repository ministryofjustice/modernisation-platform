locals {
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  # GitHub usernames for the Modernisation Platform team maintainers
  # NB: Terraform shows a perputal difference in roles if someone is an organisation owner
  # and will attempt to change them from `maintainer` to `member`, so owners should go in here.
  maintainers = [
    "ewastempel",
    "jakemulley",
    "gfou-al", # George Fountopoulos
    "SteveMarshall",
    "davidkelliott"
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
    "SteveMarshall",
    "ScottSeaward"
  ]

  # GitHub usernames for engineers who need full AWS access
  engineers = [
    "davidkelliott",
    "jakemulley",
    "stevelinden",
    "gfou-al", # George Fountopoulos,
    "dms1981", # David Sibley
    "ep-93",   # Edward Proctor
    "julialawrence",
    "ewastempel"
  ]

  # All members
  all_members = concat(local.general_members, local.engineers)

  # Everyone
  everyone = concat(local.all_maintainers, local.all_members)

  # Modernisation platform application teams (need to give access to environments repo as needed for github environments)
  # Hopefully we can get rid of this if this issue is resolved - https://github.com/ministryofjustice/operations-engineering/issues/139
  # But if not we will need to automate the updating of this list based on slugs in the environment json files.
  application_teams = [
    "all-org-members",
    "performance-hub-developers",
    "studio-webops",
    "cica",
    "xhibit-portal-dev",
    "ppud-replacement-devs",
    "threat-and-vulnerability-mgmt",
    "laa-aws-infrastructure",
    "data-and-insights-hub",
    "hmpps-digital-prison-reporting",
    "hmpps-interventions-dev",
    "hmpps-migration",
    "laa-ccms-migration-team"
  ]

  # Create a list of repositories that we want our customers to be able to contribute to
  modernisation_platform_repositories = [
    for s in data.github_repositories.modernisation-platform-repositories.names : s if startswith(s, "modernisation-platform-")
  ]
}

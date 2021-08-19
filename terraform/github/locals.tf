locals {
  # GitHub usernames for the Modernisation Platform team maintainers
  # NB: Terraform shows a perputal difference in roles if someone is an organisation owner
  # and will attempt to change them from `maintainer` to `member`, so owners should go in here.
  maintainers = [
    "ewastempel",
    "jakemulley",
    "gfou-al", # George Fountopoulos
    "philhorrocks",
    "SteveMarshall"
  ]

  # GitHub usernames for CI users
  ci_users = [
    "modernisation-platform-ci"
  ]

  # All GitHub team maintainers
  all_maintainers = concat(local.maintainers, local.ci_users)

  # GitHub usernames for team members who don't need full AWS access
  general_members = [
    "ewastempel",
    "kcbotsh",
    "nishamoj",
    "seanprivett",
    "SimonPPledger",
    "SteveMarshall",
    "christine-elliott",
  ]

  # GitHub usernames for engineers who need full AWS access
  engineers = [
    "davidkelliott",
    "donmasters",
    "ezman", # Fasih
    "jackstockley89",
    "jakemulley",
    "philhorrocks",
    "zuriguardiola",
    "stevelinden",
    "gfou-al" # George Fountopoulos
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
    "operations-engineering",
    "performance-hub-developers",
    "studio-webops"
  ]

  repositories = [
    module.core.repository.id,
    module.hello-world.repository.id,
    module.terraform-module-baselines.repository.id,
    module.terraform-module-cross-account-access.repository.id,
    module.terraform-module-environments.repository.id,
    module.terraform-module-iam-superadmins.repository.id,
    module.terraform-module-s3-bucket-replication-role.repository.id,
    module.terraform-module-s3-bucket.repository.id,
    module.terraform-module-trusted-advisor.repository.id,
    module.terraform-module-bastion-linux.repository.id,
    module.modernisation-platform-environments.repository.id
  ]
}

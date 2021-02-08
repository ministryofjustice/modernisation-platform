locals {
  # GitHub usernames for the Modernisation Platform team maintainers
  # NB: Terraform shows a perputal difference in roles if someone is an organisation owner
  # and will attempt to change them from `maintainer` to `member`, so owners should go in here.
  maintainers = [
    "ewastempel",
    "jakemulley",
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
    "davidkelliott",
    "ewastempel",
    "kcbotsh",
    "nishamoj",
    "seanprivett",
    "SimonPPledger",
    "SteveMarshall",
  ]

  # GitHub usernames for engineers who need full AWS access
  engineers = [
    "donmasters",
    "jackstockley89",
    "jakemulley",
    "philhorrocks",
    "zuriguardiola"
  ]

  # All members
  all_members = concat(local.general_members, local.engineers)

  # Everyone
  everyone = concat(local.all_maintainers, local.all_members)
}

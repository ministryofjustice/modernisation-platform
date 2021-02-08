locals {
  # GitHub usernames for the Modernisation Platform team maintainers
  # NB: Terraform shows a perputal difference in roles if someone is an organisation owner
  # and will attempt to change them from `maintainer` to `member`, so owners should go in here.
  maintainers = toset([
    "ewastempel",
    "jakemulley",
    "philhorrocks",
    "SteveMarshall"
  ])
  # GitHub usernames for the full Modernisation Platform team
  members = toset([
    "davidkelliott",
    "donmasters",
    "ewastempel",
    "jackstockley89",
    "jakemulley",
    "kcbotsh",
    "nishamoj",
    "philhorrocks",
    "seanprivett",
    "SimonPPledger",
    "SteveMarshall",
    "zuriguardiola"
  ])
  # GitHub usernames for CI users
  ci_users = toset([
    "modernisation-platform-ci"
  ])
}

locals {
  pager_duty_users = [
    {
      name  = "David Elliott"
      email = "david.elliott${local.digital_email_suffix}"
      role  = "manager"
    },
    {
      name  = "David Sibley"
      email = "david.sibley${local.digital_email_suffix}"
      role  = "user"
    }
  ]

  digital_email_suffix = "@digital.justice.gov.uk"

  existing_users = [
    data.pagerduty_user.stephen_linden,
    data.pagerduty_user.sean_privett,
    data.pagerduty_user.karen_botsh,
    data.pagerduty_user.jack_stockley,
    data.pagerduty_user.jake_mulley,
  ]

  modernisation_platform_users = concat(local.existing_users, [for user in pagerduty_user.pager_duty_users : user])

  oncall_users = concat(
    [
      local.modernisation_platform_users[index(local.modernisation_platform_users[*].name, "David Elliott")].id
    ]
  )

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}

# existing users
data "pagerduty_user" "stephen_linden" {
  email = "stephen.linden${local.digital_email_suffix}"
}

data "pagerduty_user" "sean_privett" {
  email = "sean.privett${local.digital_email_suffix}"
}

data "pagerduty_user" "karen_botsh" {
  email = "karen.botsh${local.digital_email_suffix}"
}

data "pagerduty_user" "jack_stockley" {
  email = "jack.stockley${local.digital_email_suffix}"
}

data "pagerduty_user" "jake_mulley" {
  email = "jake.mulley${local.digital_email_suffix}"
}

data "pagerduty_user" "david_elliott" {
  email = "david.elliott${local.digital_email_suffix}"
}

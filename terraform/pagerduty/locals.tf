locals {
  modernisation_platform_team_members = [
    {
      name  = "David Elliott"
      email = "david.elliott${local.digital_email_suffix}"
      role  = "manager"
    }
  ]

  digital_email_suffix = "@digital.justice.gov.uk"

  existing_users = [
    data.pagerduty_user.stephen_linden.id,
    data.pagerduty_user.sean_privett.id,
    data.pagerduty_user.karen_botsh.id,
    data.pagerduty_user.jack_stockley.id,
    data.pagerduty_user.jake_mulley.id,
    data.pagerduty_user.stephen_linden.id,
  ]

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

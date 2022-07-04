locals {

  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  pager_duty_users = {
    david_elliott = {
      name  = "David Elliott"
      email = "david.elliott${local.digital_email_suffix}"
      role  = "manager"
    },
    david_sibley = {
      name  = "David Sibley"
      email = "david.sibley${local.digital_email_suffix}"
      role  = "user"
    },
  }

  digital_email_suffix = "@digital.justice.gov.uk"

  existing_users = {
    karen_botsh    = data.pagerduty_user.karen_botsh,
    jack_stockley  = data.pagerduty_user.jack_stockley,
    jake_mulley    = data.pagerduty_user.jake_mulley,
    sean_privett   = data.pagerduty_user.sean_privett,
    stephen_linden = data.pagerduty_user.stephen_linden,
  }

  modernisation_platform_users = merge(local.existing_users, tomap(pagerduty_user.pager_duty_users))

  oncall_users = concat(
    [
      pagerduty_user.pager_duty_users["david_elliott"].id
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

data "pagerduty_user" "platforms" {
  email = "platforms${local.digital_email_suffix}"
}

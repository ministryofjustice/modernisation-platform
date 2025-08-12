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
    edward_proctor = {
      name  = "Edward Proctor"
      email = "edward.proctor${local.justice_email_suffix}"
      role  = "user"
    },
    sukesh_reddygade = {
      name  = "Sukesh Reddy Gade"
      email = "sukesh.reddygade${local.digital_email_suffix}"
      role  = "user"
    },
    mike_reid = {
      name  = "Mike Reid"
      email = "mike.reid${local.digital_email_suffix}"
      role  = "user"
    },
    kudzai_mtoko = {
      name  = "Kudzai Mtoko"
      email = "kudzai.mtoko${local.digital_email_suffix}"
      role  = "user"
    },
    modernisation_platform = {
      name  = "Modernisation Platform Team"
      email = "modernisation-platform${local.digital_email_suffix}"
      role  = "user"
    },
  }

  slack_workspace_id = "T02DYEB3A"

  digital_email_suffix = "@digital.justice.gov.uk"
  justice_email_suffix = "@justice.gov.uk"

  existing_users = {
    karen_botsh    = data.pagerduty_user.karen_botsh,
    simon_pledger  = data.pagerduty_user.simon_pledger,
    mark_roberts   = data.pagerduty_user.mark_roberts,
    aaron_robinson = data.pagerduty_user.aaron_robinson,
    richard_green  = data.pagerduty_user.richard_green,
    ewa_stempel = data.pagerduty_user.ewa_stempel
  }

  modernisation_platform_users = merge(local.existing_users, tomap(pagerduty_user.pager_duty_users))

  # oncall users local shortcut to make schedules a bit neater
  david_elliott    = pagerduty_user.pager_duty_users["david_elliott"].id
  david_sibley     = pagerduty_user.pager_duty_users["david_sibley"].id
  edward_proctor   = pagerduty_user.pager_duty_users["edward_proctor"].id
  ewa_stempel      = data.pagerduty_user.ewa_stempel.id
  mark_roberts     = data.pagerduty_user.mark_roberts.id
  aaron_robinson   = data.pagerduty_user.aaron_robinson.id
  sukesh_reddygade = pagerduty_user.pager_duty_users["sukesh_reddygade"].id
  richard_green    = data.pagerduty_user.richard_green.id

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }

  replica_region = "eu-west-1"
}

# existing users
data "pagerduty_user" "karen_botsh" {
  email = "karen.botsh${local.digital_email_suffix}"
}

data "pagerduty_user" "simon_pledger" {
  email = "simon.pledger${local.digital_email_suffix}"
}

data "pagerduty_user" "mark_roberts" {
  email = "mark.roberts${local.digital_email_suffix}"
}

data "pagerduty_user" "aaron_robinson" {
  email = "aaron.robinson1${local.justice_email_suffix}"
}

data "pagerduty_user" "richard_green" {
  email = "richard.green${local.digital_email_suffix}"
}

data "pagerduty_user" "khatra_farah" {
  email = "khatra.farah${local.digital_email_suffix}"
}

data "pagerduty_user" "ewa_stempel" {
  email = "ewa.stempel${local.justice_email_suffix}"
}

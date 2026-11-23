locals {

  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  # All user names and emails are held in the "pagerduty_users" secret, see data.tf for its format
  pagerduty_secret = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_users.secret_string)

  pager_duty_users = local.pagerduty_secret.users

  slack_workspace_id = "T02DYEB3A"

  # PagerDuty user ids by secret user key, for managed and existing users
  modernisation_platform_user_ids = merge(
    { for key, user in data.pagerduty_user.existing_users : key => user.id },
    { for key, user in pagerduty_user.pager_duty_users : key => user.id }
  )

  # rota members, in order, as PagerDuty user ids
  primary_rota_user_ids   = [for key in local.pagerduty_secret.rotas.primary : local.modernisation_platform_user_ids[key]]
  secondary_rota_user_ids = [for key in local.pagerduty_secret.rotas.secondary : local.modernisation_platform_user_ids[key]]

  tags = {
    business-unit = "Platforms"
    service-area  = "Hosting"
    application   = "Modernisation Platform"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }

  replica_region = "eu-west-1"
}

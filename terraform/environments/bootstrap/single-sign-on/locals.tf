locals {

  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  definitions-path       = "../../../../environments"
  definitions = [
    for file in fileset(local.definitions-path, "*.json") : merge({
      name = replace(file, ".json", "")
    }, jsondecode(file("${local.definitions-path}/${file}")))
  ]

  current-environment-definition = flatten([
    for application in local.definitions : [
      for environment in application.environments : concat([
        {
          account_name = "${application.name}-${environment.name}"
          github_slug  = "modernisation-platform-engineers"
          level        = "administrator"
        }
      ])
      if substr(terraform.workspace, 0, length(application.name)) == application.name && substr(terraform.workspace, length(application.name), length(terraform.workspace)) == "-${environment.name}"
    ]
  ])

  current-environment-definition_developers = try(flatten([
    for application in local.definitions : [
      for environment in application.environments : concat([
        {
          account_name = "${application.name}-${environment.name}"
          github_slug  = environment.access[0].github_slug
          level        = environment.access[0].level
        }
      ])
      if substr(terraform.workspace, 0, length(application.name)) == application.name && substr(terraform.workspace, length(application.name), length(terraform.workspace)) == "-${environment.name}"
    ]
  ]), "NO DEVELOPER GITHUB SLUG VARIABLE PROVIDED IN JSON")

  account = try({ for account_assignment in local.current-environment-definition_developers : "accounts" => account_assignment }, "NO DEVELOPER GITHUB SLUG VARIABLE PROVIDED IN JSON")

}
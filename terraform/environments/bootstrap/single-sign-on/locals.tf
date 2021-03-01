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
        for access in environment.access :
        merge(access, {
          account_name = "${application.name}-${environment.name}"
        })
        ], [
        {
          account_name = "${application.name}-${environment.name}"
          github_slug  = "modernisation-platform-engineers"
          level        = "administrator"
        }
      ])
      if substr(terraform.workspace, 0, length(application.name)) == application.name && substr(terraform.workspace, length(application.name), length(terraform.workspace)) == "-${environment.name}"
    ]
  ])
}

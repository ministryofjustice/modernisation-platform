locals {

  app_name = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, "/-([[:alnum:]]+)$/", ""))


  #app_name = replace(terraform.workspace, "/-([[:alnum:]]+)$/", "")
  env_name = replace(terraform.workspace, "${local.app_name}-", "")

  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  defname = jsondecode(file("../../../../environments/${local.app_name}.json"))

  sso_data = { for data in local.defname.environments :

    data.name => data.access

    if(data.name == local.env_name)
  }
}

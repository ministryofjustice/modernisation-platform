locals {
  application_name       = "core-sandbox"
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production    = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"
  is-preproduction = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction"

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: ${terraform.workspace}"
    is-production = local.is-production
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }

  #Required for the false condition 
  default_content = jsonencode(
        {
           networking = [
               {
                   application   = ""
                   business-unit = ""
                   set           = ""
                },
            ]
        }
    )
  
  json_data = fileexists("networking.auto.tfvars.json") ? file("networking.auto.tfvars.json") : local.default_content

  file_exists = fileexists("networking.auto.tfvars.json") ? tobool(true) : tobool(false)

  acm_pca = [substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production" || substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction" ? "acm-pca-live" : "acm-pca-non-live"]

  subnet_set = jsondecode(local.json_data).networking[0].set

  vpc_name = jsondecode(local.json_data).networking[0].business-unit 

  environment = substr(terraform.workspace, length(local.application_name), length(terraform.workspace))

  provider = "aws.core-vpc${local.environment}"
  
  }

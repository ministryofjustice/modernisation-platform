locals {
  #application_name       = "core-sandbox"
  application_name = "$application_name"
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production    = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"
  is-preproduction = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction"
  is-test          = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-test"
  is-development   = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-development"

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: ${terraform.workspace}"
    is-production = local.is-production
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }

<<<<<<< HEAD

  environment = trimprefix(terraform.workspace, "${var.networking[0].application}-")
  vpc_name = var.networking[0].business-unit 
  subnet_set = var.networking[0].set
  acm_pca = [substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production" || substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction" ? "acm-pca-live" : "acm-pca-non-live"]

  #json_data = fileexists("networking.auto.tfvars.json") ? file("networking.auto.tfvars.json") : local.default_content

  #file_exists = fileexists("networking.auto.tfvars.json") ? tobool(true) : tobool(false)
}

variable "networking" {

   type=list(any)

}

output "environment" {
  
  value = local.environment
}

output "vpc_name" {
  
  value = var.networking[0].business-unit 
}
=======
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
>>>>>>> 470cf89972b8c743e85f4bc22e93f49196c22900

output "subnet_set" {
  
  value = var.networking[0].set
}


  # #Required for the false condition 
  # default_content = jsonencode(
  #       {
  #          networking = [
  #              {
  #                  application   = ""
  #                  business-unit = ""
  #                  set           = ""
  #               },
  #           ]
  #       }
  #   )
  
  # json_data = fileexists("networking.auto.tfvars.json") ? file("networking.auto.tfvars.json") : local.default_content

  # file_exists = fileexists("networking.auto.tfvars.json") ? tobool(true) : tobool(false)

<<<<<<< HEAD
  #acm_pca = [substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production" || substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction" ? "acm-pca-live" : "acm-pca-non-live"]
=======
  vpc_name = jsondecode(local.json_data).networking[0].business-unit
>>>>>>> 470cf89972b8c743e85f4bc22e93f49196c22900

  # subnet_set = jsondecode(local.json_data).networking[0].set

<<<<<<< HEAD
  # vpc_name = jsondecode(local.json_data).networking[0].business-unit 

  # environment = substr(terraform.workspace, length(local.application_name), length(terraform.workspace))

  # provider = "aws.core-vpc${local.environment}"
  
  
=======
  provider = "aws.core-vpc${local.environment}"

}
>>>>>>> 470cf89972b8c743e85f4bc22e93f49196c22900

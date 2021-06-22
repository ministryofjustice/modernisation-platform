locals {

  
  non_conventional_account=try(regex("^bichard*.", terraform.workspace), regex("^remote-supervisio*.", terraform.workspace))

  account_name=try(local.non_conventional_account, replace(terraform.workspace, regex("-[^-]*$" ,terraform.workspace), ""))
  
  account_data = jsondecode(file("../../../../environments/${local.account_name}.json"))

}

module "cross-account-access" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=v1.0.0"
  providers = {
    aws = aws.workspace
  }
  account_id = local.modernisation_platform_account.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role_name  = "ModernisationPlatformAccess"
}

module "cicd-member-user" {

  count = local.account_data.account-type == "member" ? 1 : 0

  source = "../../../modules/iam_baseline"

  providers = {
    aws = aws.workspace
  }
}

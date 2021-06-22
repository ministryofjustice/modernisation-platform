locals {

  environment = regex("-[^-]*$", terraform.workspace)

  account_name = replace(terraform.workspace, local.environment, "")

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

  count = local.account_data.account-type != "core" || local.account_data.account-type != "member-unrestricted" ? 0 : 1

  source = "../../../modules/iam_baseline"

  providers = {
    aws = aws.workspace
  }
}

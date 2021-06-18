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

  source = "../../../modules/iam_baseline"

  providers = {
    aws = aws.workspace
  }
}
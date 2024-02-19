module "cross-account-access" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=ef80831bbc71e96733abb9ff32cc3f24bcc7e55f" #v3.0.0
  providers = {
    aws = aws.workspace
  }
  account_id             = local.modernisation_platform_account.id
  policy_arn             = "arn:aws:iam::aws:policy/AdministratorAccess"
  role_name              = "ModernisationPlatformAccess"
  additional_trust_roles = terraform.workspace == "testing-test" ? ["arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:user/testing-ci"] : []
}
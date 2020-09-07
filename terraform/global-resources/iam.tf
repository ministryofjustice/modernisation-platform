module "iam" {
  source        = "github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins"
  account_alias = "moj-modernisation-platform"
}

output "iam_superadmin_passwords" {
  value     = module.iam.superadmin_passwords
  sensitive = true
}

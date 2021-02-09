module "iam" {
  source        = "github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins?ref=v1.0.0"
  account_alias = "moj-modernisation-platform"
}

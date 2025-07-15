module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=3c182e9ad8db3c3be67cbf589a3c29c1da729154" # v6 branch
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.modernisation_platform_ou_id
  environment_prefix                 = "modernisation-platform"
}

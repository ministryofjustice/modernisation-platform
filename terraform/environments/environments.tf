module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=b78577cc957def05bbfc4edd215612fa219491cb" # v8.1.0
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.modernisation_platform_ou_id
  environment_prefix                 = "modernisation-platform"
}

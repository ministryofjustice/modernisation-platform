module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=f177dc869c27434b83818be06264a2fa68336739" # mybranch
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.modernisation_platform_ou_id
  environment_prefix                 = "modernisation-platform"
}

module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=v6.0.0"
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.environment_management.modernisation_platform_organisation_unit_id
  environment_prefix                 = "modernisation-platform"
}
module "environments" {
  providers = {
    aws = aws
  }
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments"
  environment_directory              = "../../environments"
  environment_types                  = ["production", "non-production"]
  environment_parent_organisation_id = local.environment_management.modernisation_platform_organisation_unit_id
  environment_prefix                 = "modernisation-platform"
}

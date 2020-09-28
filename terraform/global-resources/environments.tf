module "environments" {
  providers = {
    aws = aws.environments
  }
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments"
  environment_directory              = "../../environments"
  environment_types                  = ["production", "non-production"]
  environment_parent_organisation_id = local.environments_management.modernisation_platform_organisation_id
  environment_prefix                 = "modernisation-platform"
}

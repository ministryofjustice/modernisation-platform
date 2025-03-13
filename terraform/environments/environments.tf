module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=32119ae1515dce784578a86e57c54471c0da86bb" # v7.0.0
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.modernisation_platform_ou_id
  environment_prefix                 = "modernisation-platform"
}

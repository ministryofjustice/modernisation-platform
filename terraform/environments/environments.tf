module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=b17ca8d6c23a2c22d2efc6c5116a1328492c32bd" # v6.0.0
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.modernisation_platform_ou_id
  environment_prefix                 = "modernisation-platform"
}

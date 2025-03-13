module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=0f15745396a2da4627f10ad48190e07032bb9888" # v7.0.0
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.modernisation_platform_ou_id
  environment_prefix                 = "modernisation-platform"
}

module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=0cf3cc1163e06d2de51c8bc69dc16a4a586fa0a0" # v7.1.0
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.modernisation_platform_ou_id
  environment_prefix                 = "modernisation-platform"
}

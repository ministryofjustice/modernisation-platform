module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=30f855778a45a5b7446c033c67bcc1347c3cdbdd"
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.environment_management.modernisation_platform_organisation_unit_id
  environment_prefix                 = "modernisation-platform"
}
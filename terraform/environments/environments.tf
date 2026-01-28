module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=810b0385e0e0537e95ede1db2d968d323959ad5f" # v8.2.0
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.modernisation_platform_ou_id
  environment_prefix                 = "modernisation-platform"
}

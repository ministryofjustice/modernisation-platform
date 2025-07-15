module "environments" {
  source                             = "github.com/ministryofjustice/modernisation-platform-terraform-environments?ref=b80870403232132bf10fe0f8fd182201ee7ef341" # v8.0.0
  environment_directory              = "../../environments"
  environment_parent_organisation_id = local.modernisation_platform_ou_id
  environment_prefix                 = "modernisation-platform"
}

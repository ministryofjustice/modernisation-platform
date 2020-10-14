module "baselines" {
  source                = "github.com/ministryofjustice/modernisation-platform-terraform-baselines"
  baseline_directory    = "./generated"
  baseline_provider_key = "aws"
}

module "generated" {
  source                   = "./generated/aws"
  baseline_tags            = local.global_resources
  baseline_root_account_id = local.root_account.master_account_id
}

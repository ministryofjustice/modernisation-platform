module "iam" {
  source        = "github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins"
  account_alias = "moj-modernisation-platform"
}

module "auth0" {
  source                     = "github.com/ministryofjustice/modernisation-platform-terraform-iam-federated-access"
  auth0_tenant_domain        = "justice-modernisation-platform.eu.auth0.com"
  auth0_client_id            = local.auth0_saml.client_id
  auth0_client_secret        = local.auth0_saml.client_secret
  auth0_github_client_id     = local.github_saml.client_id
  auth0_github_client_secret = local.github_saml.client_secret
  auth0_github_allowed_orgs  = ["ministryofjustice"]
}

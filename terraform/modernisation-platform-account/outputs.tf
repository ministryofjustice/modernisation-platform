output "iam_superadmin_passwords" {
  value     = module.iam.superadmin_passwords
  sensitive = true
}

output "auth0_login_link" {
  value     = module.auth0.saml_login_page
  sensitive = false
}

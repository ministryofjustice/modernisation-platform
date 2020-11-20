output "iam_superadmin_passwords" {
  value     = module.iam.superadmin_passwords
  sensitive = true
}

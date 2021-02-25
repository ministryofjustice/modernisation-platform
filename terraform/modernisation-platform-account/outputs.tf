output "iam_superadmin_passwords" {
  description = "PGP-encrypted IAM superadmin passwords, if a Keybase username is provided"
  value       = module.iam.superadmin_passwords
}

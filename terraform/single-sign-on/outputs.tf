output "sandbox" {
  value = aws_ssoadmin_permission_set.modernisation_platform_sandbox.arn
}

output "migration" {
  value = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

output "instance_management" {
  value = aws_ssoadmin_permission_set.modernisation_platform_instance_management.arn
}

output "data_engineer" {
  value = aws_ssoadmin_permission_set.modernisation_platform_data_engineer.arn
}

output "reporting_operations" {
  value = aws_ssoadmin_permission_set.modernisation_platform_reporting_operations.arn
}

output "mwaa_user" {
  value = aws_ssoadmin_permission_set.modernisation_platform_data_mwaa_user.arn
}
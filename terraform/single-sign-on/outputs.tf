output "developer" {
    value = aws_ssoadmin_permission_set.modernisation_platform_developer.arn
}

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

# Data outputs
output "administrator" {
    value = data.aws_ssoadmin_permission_set.administrator.arn
}

output "view-only" {
    value = data.aws_ssoadmin_permission_set.view-only.arn
}

output "platform_engineer" {
    value = data.aws_ssoadmin_permission_set.platform_engineer.arn
}

output "security_audit" {
    value = data.aws_ssoadmin_permission_set.security_audit.arn
}

output "read_only" {
    value = data.aws_ssoadmin_permission_set.read_only.arn
}

output "ssoadmin_instances" {
    value = data.aws_ssoadmin_instances.default
}

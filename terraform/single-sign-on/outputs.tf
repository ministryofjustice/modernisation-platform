output "data_engineer" {
  value = aws_ssoadmin_permission_set.modernisation_platform_data_engineer.arn
}

output "developer" {
  value = aws_ssoadmin_permission_set.modernisation_platform_developer.arn
}

output "fleet_manager" {
  value = aws_ssoadmin_permission_set.modernisation_platform_fleet_manager.arn
}

output "instance_access" {
  value = aws_ssoadmin_permission_set.modernisation_platform_instance_access.arn
}

output "instance_management" {
  value = aws_ssoadmin_permission_set.modernisation_platform_instance_management.arn
}

output "migration" {
  value = aws_ssoadmin_permission_set.modernisation_platform_migration.arn
}

output "mwaa_user" {
  value = aws_ssoadmin_permission_set.modernisation_platform_data_mwaa_user.arn
}

output "powerbi_user" {
  value = aws_ssoadmin_permission_set.modernisation_platform_powerbi_user.arn
}

output "reporting_operations" {
  value = aws_ssoadmin_permission_set.modernisation_platform_reporting_operations.arn
}

output "sandbox" {
  value = aws_ssoadmin_permission_set.modernisation_platform_sandbox.arn
}

# Data outputs
output "administrator" {
  value = data.aws_ssoadmin_permission_set.administrator.arn
}

output "platform_engineer" {
  value = data.aws_ssoadmin_permission_set.platform_engineer.arn
}

output "platform_engineer_admin" {
  value = aws_ssoadmin_permission_set.modernisation_platform_platform_engineer_admin.arn
}

output "quicksight_admin" {
  value = aws_ssoadmin_permission_set.modernisation_platform_quicksight_admin.arn
}

output "read_only" {
  value = data.aws_ssoadmin_permission_set.read_only.arn
}

output "security_audit" {
  value = data.aws_ssoadmin_permission_set.security_audit.arn
}

output "ssm_session_access" {
  value = aws_ssoadmin_permission_set.modernisation_platform_ssm_session_access.arn
}

output "ssoadmin_instances" {
  value = data.aws_ssoadmin_instances.default
}

output "view-only" {
  value = data.aws_ssoadmin_permission_set.view-only.arn
}

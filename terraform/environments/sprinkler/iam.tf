#read only role for health check
module "iam_assumable_roles" {
  source               = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles"
  version              = "~> 2.0"
  max_session_duration = 43200

  # Read-only role
  create_readonly_role       = true
  readonly_role_name         = "readonly"
  readonly_role_requires_mfa = true

  # Allow created users to assume these roles
  trusted_role_arns = [
    data.aws_caller_identity.modernisation-platform.account_id
  ]
}

resource "aws_ses_domain_identity" "main" {
  domain = local.environment_configuration.ses_domain_identity
}

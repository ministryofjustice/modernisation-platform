resource "aws_account_alternate_contact" "infrastructure_support_operations" {

  alternate_contact_type = "OPERATIONS"

  name          = "Infrastructure Support"
  title         = "Infrastructure Support Operations"
  email_address = local.application_tags.infrastructure-support
  phone_number  = "+0000000000"
}

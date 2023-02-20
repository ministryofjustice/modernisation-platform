resource "aws_account_alternate_contact" "infrastructure_support_operations" {

  alternate_contact_type = "OPERATIONS"

  name          = "Infrastructure Support"
  title         = "Infrastructure Support Operations"
  email_address = local.application_tags.infrastructure-support
  phone_number  = "+0000000000"
}

resource "aws_account_alternate_contact" "infrastructure_support_security" {

  alternate_contact_type = "SECURITY"

  name          = "Infrastructure Support"
  title         = "Infrastructure Support Security"
  email_address = local.application_tags.infrastructure-support
  phone_number  = "+0000000000"
}

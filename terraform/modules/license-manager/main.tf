data "aws_licensemanager_received_licenses" "main" {
  provider = aws.modernisation-platform-account
  filter {
    name = "ProductSKU"
    values = [var.source_license_sku]
  }
}

resource "aws_licensemanager_grant" "main" {
  provider           = aws.modernisation-platform-account
  name               = format("%s-%d", var.destination_grant_name, var.account_to_grant)
  allowed_operations = var.destination_grant_allowed_options
  license_arn        = data.aws_licensemanager_received_licenses.main.arns[0]
  principal          = format("arn:aws:iam::%012s:root", var.account_to_grant)
}

resource "aws_licensemanager_grant_accepter" "main" {
  provider  = aws.modernisation-platform-environment
  grant_arn = aws_licensemanager_grant.main.arn
}
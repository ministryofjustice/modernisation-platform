variable "account_to_grant" {
  description = "Account IDs to grant license to"
  type        = string
}

variable "destination_grant_allowed_options" {
  description = "A list of the allowed operations for the grant."
  default = [
    "ListPurchasedLicenses",
    "CheckInLicense",
    "CheckoutLicense",
    "ExtendConsumptionLicense",
    "CreateGrant",
    "CreateToken"
  ]
  type = list(string)
}

variable "destination_grant_name" {
  type = string
}

variable "source_license_sku" {
  description = "SKU of source license visible through CLI tools query"
  type        = string
}
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

variable "source_license_arn" {
  description = "ARN of source license - eg. \"arn:aws:license-manager::$account-id:license:$license-id\"."
  type        = string
}

variable "source_grant_home_region" {
  description = "Home AWS region of source grant - eg. \"us-east-1\"."
  default     = "us-east-1"
  type        = string
}
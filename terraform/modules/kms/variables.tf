variable "business_unit" {
  description = "String describing the business unit. EG, CJSE"
}

variable "business_unit_account_ids" {
  description = "List of account IDs permitted to utilise key."
}

variable "tags" {
  description = "Map of tags to apply to KMS keys."
}
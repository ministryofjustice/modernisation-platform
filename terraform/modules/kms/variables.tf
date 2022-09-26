variable "business_unit" {
  description = "String describing the business unit. EG, CJSE"
  type        = string
}

variable "business_unit_account_ids" {
  description = "List of account IDs permitted to utilise key."
  type        = list(any)
}

variable "tags" {
  description = "Map of tags to apply to KMS keys."
  type        = map(any)
}
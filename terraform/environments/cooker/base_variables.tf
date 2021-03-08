variable "business_unit" {
  type        = string
  default     = "BUSINESS_UNIT"
  description = "Fixed variable to specify business-unit for RAM shared subnets"
}
variable "subnet_set" {
  type        = string
  default     = "SUBNET_SET"
  description = "Fixed variable to specify subnet-set for RAM shared subnets"
}
variable "account_name" {
  type        = string
  default     = "ACCOUNT_NAME"
  description = "account name without environment name excluded - can be used to extract environment from workspace name"
}
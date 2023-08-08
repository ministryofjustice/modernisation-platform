variable "business_unit" {
  type        = string
  default     = "hmpps"
  description = "Fixed variable to specify business-unit for RAM shared subnets"
}

variable "subnet_set" {
  type        = string
  default     = "nomis"
  description = "Fixed variable to specify subnet-set for RAM shared subnets"
}

variable "account_name" {
  type        = string
  default     = "core-sandbox"
  description = "account name without environment name excluded - can be used to extract environment from workspace name"
}


variable "networking" {
  type    = list(any)
  default = [
    {
      "business-unit": "",
      "set": "",
      "application": "core-sandbox"
    }
  ]
}

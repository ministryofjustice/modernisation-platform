variable "networking" {
  type = list(any)
  default = [
    {
      "business-unit" : "",
      "set" : "",
      "application" : "core-shared-services"
    }
  ]
}

variable "app_name" {
  type    = string
  default = "performance-hub"
}

variable "account_arns" {
  description = "list of account arns"
  type        = list(string)
  default     = []
}
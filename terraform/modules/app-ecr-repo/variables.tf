variable "tags_common" {
  description = "MOJ required tags"
  type        = map(string)
}

variable "app_name" {
  description = "base name for ecr repo"
  type        = string
}

variable "account_arns" {
  description = "accounts arns"
  type        = list(string)
  default     = []
}
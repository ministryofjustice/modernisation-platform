variable "networking" {

  type = list(any)

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
variable "datasource_names" {
  type = list(string)
}

variable "role_name" {
  type    = string
  default = "observability-platform"
}

variable "environment_management" {
  type = any
}

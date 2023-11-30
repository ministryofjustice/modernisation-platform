variable "workspace_arn" {
  type = string
}

variable "datasource_names" {
  type = list(string)
}

variable "environment_management" {
  type = any
}

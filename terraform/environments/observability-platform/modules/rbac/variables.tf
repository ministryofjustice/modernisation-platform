variable "grafana_rbac" {
  type = map(object({
    accounts = list(string)
  }))
}

variable "workspace_id" {
  type = string
}
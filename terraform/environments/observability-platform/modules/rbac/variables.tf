variable "grafana_rbac" {
  type = map(object({
    accounts = list(string)
    permission = string
  }))
  description = "Map a grafana team name (key) to github teams (accounts) and give permissions"
}

variable "workspace_id" {
  type = string
}
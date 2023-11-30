variable "team_config" {
  type = object({
    sso_uuid           = string
    cloudwatch_sources = list(string)
  })
  description = "Map of team configuration"
}

variable "team_name" {
  type = string
}

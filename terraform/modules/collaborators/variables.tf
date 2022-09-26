variable "username" {
  description = "User name"
  type        = string
}

variable "accounts" {
  description = "List of accounts to give access to with access levels"
  type        = list(any)
}

variable "environment_management" {
  description = "Environment management json"
  type = object({
    account_ids                                 = map(string)
    aws_organizations_root_account_id           = string
    modernisation_platform_account_id           = string
    modernisation_platform_organisation_unit_id = string
  })
}

variable "application_teams" {
  description = "A list of github slugs that corresponds to modernisation platform customers"
  type        = list(string)
}
variable "repository_id" {
  description = "The name of the repository in scope for additional permissions"
  type        = string
}
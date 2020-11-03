variable "name" {
  description = "Team name"
  type        = string
}

variable "description" {
  description = "Team description"
  type        = string
}

variable "repositories" {
  description = "Repositories to give the team access to"
  type        = set(string)
}

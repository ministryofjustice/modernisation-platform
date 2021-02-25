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
  default     = []
}

variable "maintainers" {
  description = "GitHub team maintainers"
  type        = set(string)
  default     = []
}

variable "members" {
  description = "GitHub team members"
  type        = set(string)
  default     = []
}

variable "ci" {
  description = "GitHub team members who run as CI"
  type        = set(string)
  default     = []
}

variable "parent_team_id" {
  description = "GitHub team ID for parent teams"
  type        = string
  default     = null
}

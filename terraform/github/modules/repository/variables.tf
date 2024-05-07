variable "name" {
  type        = string
  description = "Repository name"
}

variable "description" {
  type        = string
  description = "Repository description"
}

variable "homepage_url" {
  type        = string
  description = "Repository homepage URL"
  default     = ""
}

variable "secrets" {
  type        = map(any)
  description = "key:value map for GitHub actions secrets"
  default     = {}
}

variable "topics" {
  type        = list(string)
  description = "Repository topics, in addition to 'modernisation-platform', 'terraform-module', 'civil-service'"
}

variable "type" {
  type        = string
  description = "Type of repository: `core`, `module`, `template`. Defaults to `core`"
  default     = "core"
}

variable "visibility" {
  type        = string
  description = "Visibility type: `public`, `internal`, `private`"
  default     = "public"
}

variable "required_checks" {
  type        = list(string)
  description = "List of required checks"
  default     = []
}

variable "restrict_dismissals" {
  type        = bool
  description = "Restrict pull request review dismissals"
  default     = false
}

variable "dismissal_restrictions" {
  type        = list(string)
  description = "The list of actor Names/IDs with dismissal access e.g. 'exampleorganization/exampleteam' or '/exampleuser'"
  default     = []
}

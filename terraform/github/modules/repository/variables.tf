variable "name" {
  type        = string
  description = "Repository name"
}

variable "description" {
  type        = string
  description = "Repository description"
}

variable "dismissal_restrictions" {
  type        = list(string)
  description = "The list of actor Names/IDs with dismissal access e.g. 'exampleorganization/exampleteam' or '/exampleuser'"
  default     = []
}

variable "homepage_url" {
  type        = string
  description = "Repository homepage URL"
  default     = ""
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

variable "secrets" {
  type        = map(any)
  description = "key:value map for GitHub actions secrets"
  default     = {}
}

variable "squash_merge_commit_message" {
  type        = bool
  description = "Should squash merge commit message be set to MERGE_MESSAGE?"
  default     = true
}

variable "squash_merge_commit_title" {
  type        = bool
  description = "Should squash merge commit title be set to PR_TITLE?"
  default     = true
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

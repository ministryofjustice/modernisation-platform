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
  description = "Type of repository: `core`, `module`. Defaults to `module`"
  default     = "module"
}

variable "visibility" {
  type        = string
  description = "Visibility type: `public`, `internal`, `private`"
  default     = "public"
}

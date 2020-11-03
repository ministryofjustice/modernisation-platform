variable "name" {
  type        = string
  description = "Repository name"
}

variable "description" {
  type        = string
  description = "Repository description"
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

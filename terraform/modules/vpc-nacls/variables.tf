variable "nacl_config" {
  description = "List of maps of NACLs configurations"
  type        = list(any)
}

variable "nacl_refs" {
  description = "Map of internal NACL references including arn, id, and name"
  type        = map(any)
}

variable "tags_prefix" {
  description = "Prefix for name tags"
  type        = string
}

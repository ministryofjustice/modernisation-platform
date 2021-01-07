variable "nacl_config" {
  type = list(any)
}

variable "nacl_refs" {
  type = map(any)
}

variable "tags_common" {
  description = "MOJ required tags"
  type        = map(string)
}

variable "tags_prefix" {
  description = "prefix for name tags"
  type        = string
}

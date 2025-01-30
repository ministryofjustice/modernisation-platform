variable "tags_common" {
  description = "MOJ required tags"
  type        = map(string)
}

variable "tags_prefix" {
  description = "prefix for name tags"
  type        = string
}

variable "resource_arns" {
  description = "Resource ARNs to attach to a resource share"
  type        = map(string)
}

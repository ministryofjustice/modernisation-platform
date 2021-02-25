variable "dns_zone" {
  type = string
}

variable "vpc_id" {
}

variable "accounts" {
  type = map(any)
}

variable "environments" {
}

#TAGS
variable "tags_common" {
  description = "MOJ required tags"
  type        = map(string)
}

variable "tags_prefix" {
  description = "prefix for name tags"
  type        = string
}
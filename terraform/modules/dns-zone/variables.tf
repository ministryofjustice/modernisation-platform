variable "dns_zone" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "accounts" {
  type = map(any)
}

variable "modernisation_platform_account" {
  type = string
}


variable "environments" {
  type = any
}

variable "public_dns_zone" {
  type = any
}

variable "private_dns_zone" {
  type = any
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

variable "monitoring_sns_topic" {
  type = string
}

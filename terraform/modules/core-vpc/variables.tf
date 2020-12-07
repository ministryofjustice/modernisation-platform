variable "vpc_cidr" {
  type = string
}

variable "subnet_cidrs_by_type" {
  description = "Map of subnet CIDR blocks with the keys representing what they are for"
  type        = map
}

variable "tags_common" {
  description = "MOJ required tags"
  type        = map(string)
}

variable "tags_prefix" {
  description = "prefix for name tags"
  type        = string
}

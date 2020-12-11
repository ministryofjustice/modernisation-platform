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

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway on this VPC"
  type        = bool
  default     = false
}

variable "shared_resource" {
  description = ""
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  description = ""
  type = string
  default = ""
}

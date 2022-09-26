variable "subnet_sets" {
  description = "Key, value map of subnet sets and their CIDR blocks"
  type        = map(any)
}

variable "route_table" {
  description = "Route Table"
  type        = any
}

variable "tgw_id" {
  description = "Transit Gateway ID"
  type        = string
}

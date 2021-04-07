variable "subnet_sets" {
  description = "Key, value map of subnet sets and their CIDR blocks"
  type        = map(any)
}

variable "tgw_vpc_attachment" {
  description = "Transit Gateway VPC attachment ID"
  type        = string
}

variable "tgw_route_table" {
  description = "Transit Gateway route table ID"
  type        = string
}

variable "route_table" {
  description = "Route Table"
}

variable "tgw_id" {
  description = "Transit Gateway ID"
  type        = string
}

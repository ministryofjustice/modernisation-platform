variable "vpc_name" {
  description = "VPC name used to lookup routing tables"
  type        = string
}

variable "vpc_cidr_range" {
  description = "VPC CIDR range to add to Transit Gateway routing table"
  type        = string
}

variable "tgw_vpc_attachment" {
  description = "Transit Gateway VPC attachment ID"
  type        = string
}

variable "tgw_route_table" {
  description = "Transit Gateway route table ID"
  type        = string
}

variable "tgw_id" {
  description = "Transit Gateway ID"
  type        = string
}

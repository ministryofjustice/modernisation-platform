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

variable "tgw_id" {
  description = "Transit Gateway ID"
  type        = string
}

variable "type" {
  description = "Type of Routing table (live_data / non_live_data)" 
  type        = string

  validation {
    condition     = var.type == "live_data" || var.type == "non_live_data"
    error_message = "Accepted values are live_data, non_live_data."
  }
}
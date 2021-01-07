variable "subnet_ids" {
  description = "Subnet IDs to attach to the Transit Gateway"
  type        = list(string)
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID to attach to"
  type        = string

}

variable "vpc_id" {
  description = "VPC ID to attach to the Transit Gateway"
  type        = string
}

variable "tags" {
  description = "Tags to attach to resources, where applicable"
  type        = map(any)
}

variable "type" {
  description = "Type of Transit Gateway to attach to"
  type        = string

  validation {
    condition     = can(regex("^live_data|non_live_data", var.type))
    error_message = "Accepted values are live_data, non_live_data."
  }
}

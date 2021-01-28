variable "resource_share_name" {
  description = "Resource Access Manager (RAM) resource share name to lookup the Transit Gateway Resource Share"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to attach to the Transit Gateway"
  type        = list(string)
}

variable "tags" {
  description = "Tags to attach to resources, where applicable"
  type        = map(any)
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID to attach to"
  type        = string
}

variable "type" {
  description = "Type of Transit Gateway to attach to"
  type        = string

  validation {
    condition     = var.type == "live_data" || var.type == "non_live_data"
    error_message = "Accepted values are live_data, non_live_data."
  }
}

variable "vpc_id" {
  description = "VPC ID to attach to the Transit Gateway"
  type        = string
}

variable "vpc_name" {
  description = "VPC name (used for tagging)"
  type        = string
}

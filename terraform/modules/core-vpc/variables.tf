variable "vpc_cidr" {
  type = string
}

# variable "subnet_cidrs_by_type" {
#   description = "Map of subnet CIDR blocks with the keys representing what they are for"
#   type        = map(any)
# }

variable "tags_common" {
  description = "MOJ required tags"
  type        = map(string)
}

variable "tags_prefix" {
  description = "prefix for name tags"
  type        = string
}

variable "gateway" {
  description = "Type of Gateway to use for environment"
  type        = string
  default     = "none"
  validation {
    condition     = var.gateway == "transit" || var.gateway == "nat" || var.gateway == "none"
    error_message = "Must provide either transit, nat or none."
  }

}

variable "shared_resource" {
  description = ""
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  description = ""
  type        = string
  default     = ""
}

variable "nacl_ingress" {
  description = "List of NACL ingress rules"
  type        = map(any)
  default     = null
}

variable "nacl_egress" {
  description = "List of NACL egress rules"
  type        = map(any)
  default     = null
}

variable "vpc_flow_log_iam_role" {
  description = "VPC Flow Log IAM role ARN for VPC Flow Logs to CloudWatch"
  type        = string
}

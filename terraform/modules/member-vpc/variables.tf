variable "transit" {
  type = string
}

variable "protected" {
  type = string
}

variable "subnet_sets" {
  type = map(any)
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

variable "transit_gateway_id" {
  description = "tgw ID"
  type        = string
}

variable "additional_endpoints" {
  description = "additional endpoints required for VPC"
  type        = list(any)
}

variable "bastion_linux" {
  description = ""
  type        = bool
  default     = false
}

variable "bastion_windows" {
  description = ""
  type        = bool
  default     = false
}


# variable "enable_nat_gateway" {
#   description = "Enable NAT Gateway on this VPC"
#   type        = bool
#   default     = false
# }

# variable "shared_resource" {
#   description = ""
#   type        = bool
#   default     = false
# }

# variable "transit_gateway_id" {
#   description = ""
#   type        = string
#   default     = ""
# }

# variable "nacl_ingress" {
#   description = "List of NACL ingress rules"
#   type = map(any)
#   default = null
# }

# variable "nacl_egress" {
#   description = "List of NACL egress rules"
#   type = map(any)
#   default = null
# }

variable "vpc_flow_log_iam_role" {
  description = "VPC Flow Log IAM role ARN for VPC Flow Logs to CloudWatch"
  type        = string
}

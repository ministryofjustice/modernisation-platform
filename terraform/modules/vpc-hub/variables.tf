variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "gateway" {
  description = "Type of gateway to use for environment"
  type        = string
  default     = "none"
  validation {
    condition     = var.gateway == "transit" || var.gateway == "nat" || var.gateway == "none"
    error_message = "Must provide either `transit`, `nat` or `none`."
  }
}

variable "transit_gateway_id" {
  description = "tgw ID"
  type        = string
  default     = ""
}
variable "vpc_flow_log_iam_role" {
  description = "VPC Flow Log IAM role ARN for VPC Flow Logs to CloudWatch"
  type        = string
}

variable "tags_common" {
  description = "Ministry of Justice required tags"
  type        = map(any)
}

variable "tags_prefix" {
  description = "Prefix for name tags, e.g. \"live_data\""
  type        = string
}

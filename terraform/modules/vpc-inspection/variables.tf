variable "fw_policy_arn" {
  description = "ARN of policy to be supplied to inline-inspection firewall"
}

variable "tags_common" {
  description = "Ministry of Justice required tags"
  type        = map(any)
}

variable "tags_prefix" {
  description = "Prefix for name tags, e.g. \"live_data\""
  type        = string
}

variable "transit_gateway_id" {
  default = ""
  type    = string
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "vpc_flow_log_iam_role" {
  description = "VPC Flow Log IAM role ARN for VPC Flow Logs to CloudWatch"
  type        = string
}
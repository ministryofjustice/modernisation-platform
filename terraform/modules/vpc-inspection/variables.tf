variable "application_name" {
  description = "Application name, eg `core-shared-services` or `core-network-services"
  type        = string
}

variable "fw_allowed_domains" {
  description = "List of strings containing allowed domains"
  type        = list(string)
}

variable "fw_home_net_ips" {
  description = "List of strings covering firewall HOME_NET values"
  type        = list(string)
}

variable "fw_rules" {
  description = "JSON map of maps containing stateless firewall rules"
  type        = map(any)
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
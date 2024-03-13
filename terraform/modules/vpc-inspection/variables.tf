variable "application_name" {
  description = "Application name, eg `core-shared-services` or `core-network-services"
  type        = string
}

variable "cloudwatch_kms_key_id" {
  default     = ""
  description = "Optional KMS key ID to use in encrypting VPC flow logs CloudWatch group."
  type        = string
}

variable "fw_allowed_domains" {
  description = "List of strings containing allowed domains"
  type        = list(string)
}

variable "fw_delete_protection" {
  description = "Boolean to enable or disable firewall deletion protection"
  default     = true
  type        = bool
}

variable "fw_home_net_ips" {
  description = "List of strings covering firewall HOME_NET values"
  type        = list(string)
}

variable "fw_kms_arn" {
  description = "KMS key ARN used for firewall encryption"
  type        = string
}

variable "fw_managed_rule_groups" {
  description = "Names of AWS managed rule groups from https://docs.aws.amazon.com/network-firewall/latest/developerguide/aws-managed-rule-groups-threat-signature.html"
  type        = list(string)
  default     = []
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

variable "xsiam_network_endpoint" {
  description = "The http endpoint URL for the transfer of VPC flowlog data via firehose"
  type        = string
}

variable "xsiam_network_secret" {
  description = "The secret for the vpc flow log xsiam http endpoint"
  type        = string
}

variable "xsiam_firewall_endpoint" {
  description = "The http endpoint URL for the transfer of firewall log data via firehose"
  type        = string
}

variable "xsiam_firewall_secret" {
  description = "The secret for the firewall xsiam http endpoint"
  type        = string
}

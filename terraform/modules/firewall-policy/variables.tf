variable "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group to ship logs to"
  type        = string
}

variable "fw_arn" {
  description = "ARN of firewall for logging configuration"
  type        = string
}

variable "fw_policy_name" {
  type = string
}

variable "fw_rulegroup_capacity" {
  default = "10000"
  type    = string
}

variable "fw_rulegroup_name" {
  type = string
}

variable "rules" {
  description = "A map of values supplied to create firewall rules"
  type        = map(any)
}
variable "tags" {
  description = "A map of keys and values used to create resource metadata tags"
  type        = map(any)
}

variable "list_of_allowed_domains" {
  type = list(string)
}
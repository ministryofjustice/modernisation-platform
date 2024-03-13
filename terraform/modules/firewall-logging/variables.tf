variable "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group to ship logs to"
  type        = string
}

variable "fw_arn" {
  description = "ARN of firewall for logging configuration"
  type        = string
}

variable "fw_name" {
  description = "Name of firewall to identify whether live or non-line"
  type        = string
}

variable "tags" {
  description = "A map of keys and values used to create resource metadata tags"
  type        = map(any)
}
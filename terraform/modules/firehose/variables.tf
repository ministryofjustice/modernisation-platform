
variable "tags" {
  description = "A map of keys and values used to create resource metadata tags"
  type        = map(any)
}

variable "resource_prefix" {
  description = "The prefix to be used for the resource names - used for easy identification"
  type        = string
}

variable "log_group_name" {
  description = "The name of the log group that the subscription will be added to"
  type        = string
}

variable "xsiam_endpoint" {
  description = "The http endpoint URL for the transfer of log data via firehose"
  type        = string
}

variable "xsiam_secret" {
  description = "The secret for the xsiam http endpoint"
  type        = string
}
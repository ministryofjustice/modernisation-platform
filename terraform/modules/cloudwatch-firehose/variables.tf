variable "cloudwatch_log_groups" {
  type        = list(string)
  description = "List of CloudWatch Log Group names to stream logs from."
}

variable "destination_bucket_arn" {
  type        = string
  description = "ARN of the bucket for CloudWatch filters."
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to be applied to resources."
}
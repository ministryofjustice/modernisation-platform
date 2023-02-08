variable "logging_destination_arn" {
  type        = string
  description = "ARN for destination of Route53 resolver logs. EG, a CloudWatch log group"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to turn on resolver logs"
}

variable "tags_common" {
  description = "Ministry of Justice required tags"
  type        = map(string)
}
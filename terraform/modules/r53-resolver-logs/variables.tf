variable "logging_destination_arn" {
  type        = string
  description = "ARN for destination of Route53 resolver logs. EG, a CloudWatch log group"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to turn on resolver logs"
}

variable "tags_common" {
  description = "Map of tags"
  type        = map(string)
}
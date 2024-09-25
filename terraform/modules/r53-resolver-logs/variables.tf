variable "s3_destination_arn" {
  type        = string
  default     = ""
  description = "S3 Bucket ARN to receive resolver logs"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to associate with resolver log query config"
}

variable "vpc_name" {
  type        = string
  description = "VPC name used in title of logs"
}

variable "tags_common" {
  description = "Map of tags"
  type        = map(string)
}
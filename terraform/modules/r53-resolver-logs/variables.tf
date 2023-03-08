variable "vpc_id" {
  type        = string
  description = "VPC ID to turn on resolver logs"
}

variable "vpc_name" {
  type        = string
  description = "VPC name used in title of logs"
}

variable "tags_common" {
  description = "Map of tags"
  type        = map(string)
}
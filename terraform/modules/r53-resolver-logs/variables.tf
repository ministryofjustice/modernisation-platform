variable "vpc_id" {
  type        = string
  description = "VPC ID to turn on resolver logs"
}

variable "tags_common" {
  description = "Map of tags"
  type        = map(string)
}
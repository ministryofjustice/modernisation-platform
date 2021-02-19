variable "vpc_cidr" {
  description = ""
  type        = string
}

variable "gateway" {
  description = ""
  type        = string
}

variable "vpc_flow_log_iam_role" {
  description = ""
  type        = string
}

variable "tags_common" {
  description = ""
  type        = map(any)
}

variable "tags_prefix" {
  description = ""
  type        = string
}

variable "principal" {
  description = "Principal to share with"
  type        = string
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "subnet_set" {
  description = "Subnet set to attach to"
  type        = string
}

variable "acm_pca" {
  description = "ACM certificate manager"
  type        = string

}

variable "environment" {

  description = "environment"
  type        = string
}

variable "enable_secondary_share" {
  description = "Whether to lookup and associate secondary CIDR resource share (determined automatically from environments-networks config)"
  type        = bool
  default     = false
}
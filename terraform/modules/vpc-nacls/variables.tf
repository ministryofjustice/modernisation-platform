variable "additional_vpcs" {
  description = "A list of strings containing names of external MP VPCs needing access. EG. [\"platforms-development\"]"
  type        = list(string)
  default     = []
}

variable "additional_cidrs" {
  description = "A list of strings containing cidr blocks of external networks which require private connectivity such as PSN addresses."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to network ACL resources"
  type        = map(string)
  default     = {}
}

variable "tags_prefix" {
  description = "Prefix for name tags"
  type        = string
}

variable "vpc_name" {
  description = "Selected VPC for NACL creation"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for NACL creation"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string

}

variable "data_subnet_ids" {
  description = "List of data subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "protected_subnet_ids" {
  description = "List of protected subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
} 
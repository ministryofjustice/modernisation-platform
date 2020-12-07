variable "subnet_azs" {
  default = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c",
  ]
}

variable "vpc_cidr" {
  type = string
}

variable "tgw_cidr_blocks" {
  type = list
}

variable "private_cidr_blocks" {
  type = list
}

variable "public_cidr_blocks" {
  type = list
}

variable "tags_common" {
  description = "MOJ required tags"
  type        = map(string)
}

variable "tags_prefix" {
  description = "prefix for name tags"
  type        = string
}

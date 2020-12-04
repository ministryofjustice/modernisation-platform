variable "subnet_azs" {
  default = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c",
  ]
}

## live VPC variables
variable "live_vpc_cidr" {
  type    = string
  default = "10.230.0.0/19"
}

# Private TGW CIDR blocks for live
variable "live_private_tgw_cidr_blocks" {
  type = list
  default = [
    "10.230.0.0/28",
    "10.230.0.16/28",
    "10.230.0.32/28"
  ]
}

variable "live_private_cidr_blocks" {
  type = list
  default = [
    "10.230.8.0/23",
    "10.230.10.0/23",
    "10.230.12.0/23"
  ]
}

variable "live_public_cidr_blocks" {
  type = list
  default = [
    "10.230.2.0/23",
    "10.230.4.0/23",
    "10.230.6.0/23"
  ]
}


## Non live VPC variables
variable "non_live_vpc_cidr" {
  type    = string
  default = "10.230.32.0/19"
}

variable "non_live_private_tgw_cidr_blocks" {
  type = list
  default = [
    "10.230.32.0/28",
    "10.230.32.16/28",
    "10.230.32.32/28"
  ]
}

variable "non_live_private_cidr_blocks" {
  type = list
  default = [
    "10.230.40.0/23",
    "10.230.42.0/23",
    "10.230.44.0/23"
  ]
}

variable "non_live_public_cidr_blocks" {
  type = list
  default = [
    "10.230.34.0/23",
    "10.230.36.0/23",
    "10.230.38.0/23"
  ]
}

variable "subnet_azs" {
  default = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c",
  ]
}

##################################
#Transit gateway variables
##################################
variable "env_vpcs" {
  description = "environment vpcs"
  type        = list
  default     = ["live", "non-live"]
}
variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway"
  type        = string
  default     = "64589"
}
variable "enable_auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted"
  type        = bool
  default     = false
}
variable "default_propagation_route_table" {
  description = "Boolean whether this is the default association route table for the EC2 Transit Gateway."
  type        = bool
  default     = false
}
variable "enable_default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default association route table"
  type        = bool
  default     = false
}
variable "enable_default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default propagation route table"
  type        = bool
  default     = false
}
variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the TGW"
  type        = bool
  default     = true
}
variable "enable_attachment_ipv6_support" {
  description = "Should be true to enable DNS support in the TGW"
  type        = string
  default     = "disable"
}
variable "enable_vpn_ecmp_support" {
  description = "Whether VPN Equal Cost Multipath Protocol support is enabled"
  type        = bool
  default     = true
}

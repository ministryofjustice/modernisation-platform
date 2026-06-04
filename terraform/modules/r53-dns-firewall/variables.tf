variable "tags_prefix" {
  description = "Prefix for name tags, e.g. the name of the VPC for unique identification of resources"
  type        = string
}

variable "tags_common" {
  description = "Ministry of Justice required tags"
  type        = map(any)
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with the DNS Firewall rule group"
  type        = string
}

variable "association_priority" {
  description = "Priority of the firewall rule group association"
  type        = number
  default     = 101
}

variable "block_response" {
  description = "The way that you want DNS Firewall to block the request. Supported Valid values are NODATA, NXDOMAIN, or OVERRIDE"
  type        = string
  default     = "NXDOMAIN"
}
variable "allowed_domains" {
  description = "List of allowed domains"
  type        = list(string)
  default     = []
}

variable "blocked_domains" {
  description = "List of blocked domains"
  type        = list(string)
  default     = []
}

variable "pagerduty_integration_key" {
  description = "The PagerDuty integration key"
  type        = string
}
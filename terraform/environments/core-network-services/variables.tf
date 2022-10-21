variable "address-data" {
  description = "JSON route data"
  default     = "routes"
}
variable "address_definition" {
  description = "IP address of accepted source"
  type = map(string)
  default = {}
  }
variable "source_port" {
  description = "IP address of source port"
  type = map(string)
  default = {}
}
variable "destination_port" {
  description = "IP address of destination port"
  type = map(string)
  default = {}
}
variable "protocols" {
  description = "Protocol to be used"
  type = map(string)
  default = {}
}
variable "fw_policy_name" {
  default = "blank"
}
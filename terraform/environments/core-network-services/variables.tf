variable "address-data" {
  description = "JSON route data"
  default = "routes"
}

variable "address_definition" {
  description = "IP address of accepted source"
  default = "0.0.0.0/0"
}
variable "source_port" {
  description = "IP address of source port"
  default = 0
}
variable "destination_port" {
  description = "IP address of destination port"
  default = 0
}
variable "protocols" {
  description = "Protocol to be used"
  default = "VPC"
}
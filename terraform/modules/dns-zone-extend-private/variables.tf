variable "zone_name" {
  description = "Name of private DNS zone passed into module for lookup."
  type        = map(any)
}

variable "vpc_id" {
  description = "ID of the VPC to be associated with the private DNS zone."
  type        = string
}

variable "business_unit_name" {
  description = "Variable for passing account name to module for dns lookup"
  type = string
}

variable "vpc_id" {
  description = "Variable for the vpc id to be passed to the module"
  type = string
}

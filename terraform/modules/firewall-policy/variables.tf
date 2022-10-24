variable "fw_policy_name" {
  type = string
}

variable "fw_rulegroup_capacity" {
  default = "30000"
  type    = string
}

variable "fw_rulegroup_name" {
  type = string
}

variable "rules" {
  description = "A map of values supplied to create firewall rules"
  type        = map(any)
}
variable "tags" {
  type = map(any)
}
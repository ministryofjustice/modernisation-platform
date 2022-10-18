variable "fw_policy_name" {}

variable "fw_rulegroup_capacity" {
  default = "10000"
}

variable "fw_rulegroup_name" {}

variable "rules" {
  description = "A map of values supplied to create firewall rules"
}
variable "tags" {}
variable "fw_allowed_domains" {
  description = "A list of domain names that will be added to an allow list rule"
  type        = list(string)
}

variable "fw_home_net_ips" {
  description = "A list of VPC cidr ranges that will be added to the HOME_NET for VPC scanning"
  type        = list(string)
}

variable "fw_fqdn_rulegroup_capacity" {
  description = "rule group capacity for FQDN rule group"
  default     = "3000"
  type        = string
}

variable "fw_fqdn_rulegroup_name" {
  type = string
}

variable "fw_kms_arn" {
  description = "ARN of KMS key used for encryption at rest"
  type        = string
}

variable "fw_managed_rule_groups" {
  description = "Names of AWS managed rule groups from https://docs.aws.amazon.com/network-firewall/latest/developerguide/aws-managed-rule-groups-threat-signature.html"
  type        = list(string)
  default     = []
}

variable "fw_policy_name" {
  type = string
}

variable "fw_rulegroup_capacity" {
  default = "10000"
  type    = string
}

variable "fw_rulegroup_name" {
  type = string
}

variable "port_sets" {
  description = "A map of lists for firewall port sets. EG {\"HTTP\" = [\"80\", \"443\"]
  type = map(any)
}

variable "rules" {
  description = "A map of values supplied to create firewall rules"
  type        = map(any)
}

variable "tags" {
  description = "A map of keys and values used to create resource metadata tags"
  type        = map(any)
}
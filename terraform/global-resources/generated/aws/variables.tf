variable "baseline_assume_role" {
  type        = string
  description = "Role ARN to assume to manage these resources"
  default     = ""
}

variable "baseline_tags" {
  type        = map
  description = "Tags to apply to taggable resources"
}

variable "baseline_root_account_id" {
  type        = string
  description = "The AWS Organisations root account ID that this account should be part of"
}

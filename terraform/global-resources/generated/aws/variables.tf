variable "baseline_assume_role" {
  type        = string
  description = "Which role to assume to manage these resources"
  default     = ""
}

variable "baseline_tags" {
  type        = map
  description = "Tags to apply to taggable resources"
}

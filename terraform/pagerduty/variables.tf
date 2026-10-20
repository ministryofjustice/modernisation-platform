variable "pagerduty_token" {
  description = "PagerDuty token"
  type        = string
  sensitive   = true
}

variable "pagerduty_user_token" {
  description = "PagerDuty user token"
  type        = string
  sensitive   = true

}

variable "pagerduty_status_page_id" {
  description = "PagerDuty Status Page ID for the Modernisation Platform external status page"
  type        = string
  default     = "PN2KMAZ" # MP external status dashboard
}
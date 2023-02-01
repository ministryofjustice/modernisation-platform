
    # business-unit = "Platforms"
    # application   = "Modernisation Platform: ${terraform.workspace}"
    # is-production = local.is-production
    # owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"


variable "vpc_id" {
  type        = string
  description = "VPC ID to turn on resolver logs"
}
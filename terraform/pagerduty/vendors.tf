data "pagerduty_vendor" "guard_duty" {
  name = "Amazon GuardDuty"
}

data "pagerduty_vendor" "cloudwatch" {
  name = "Amazon CloudWatch"
}

data "pagerduty_vendor" "cloudtrail" {
  name = "AWS CloudTrail"
}

data "pagerduty_vendor" "security_hub" {
  name = "AWS Security Hub"
}
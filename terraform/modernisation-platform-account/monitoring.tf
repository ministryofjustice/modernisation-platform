module "pagerduty_core_alerts" {
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=d88bd90d490268896670a898edfaba24bba2f8ab" # v3.0.0
  sns_topics                = ["config", "securityhub-alarms", "cloudtrail"]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]
}

moved {
  from = module.core_monitoring.module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["cloudtrail"]
  to   = module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["cloudtrail"]
}

moved {
  from = module.core_monitoring.module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["config"]
  to   = module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["config"]
}

moved {
  from = module.core_monitoring.module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["securityhub-alarms"]
  to   = module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["securityhub-alarms"]
}

# Suppresses Security Hub control S3.6 for the terraform state bucket.
# This bucket requires controlled cross-account access for
# Modernisation Platform environments.
# Risk reviewed and accepted.
resource "aws_securityhub_automation_rule" "suppress_tf_state_bucket_cross_account" {
  rule_name   = "suppress-tf-state-bucket-cross-account-policy"
  rule_order  = 1
  description = "Suppress Security Hub S3.6 finding for terraform state bucket"

  criteria {
    resource_id {
      comparison = "EQUALS"
      value      = "arn:aws:s3:::modernisation-platform-terraform-state"
    }

    security_control_id {
      comparison = "EQUALS"
      value      = "S3.6"
    }
  }

  actions {
    type = "FINDING_FIELDS_UPDATE"

    finding_fields_update {
      workflow {
        status = "SUPPRESSED"
      }

      note {
        text       = "Approved exception - Terraform backend requires controlled cross-account access."
        updated_by = "terraform"
      }
    }
  }
}


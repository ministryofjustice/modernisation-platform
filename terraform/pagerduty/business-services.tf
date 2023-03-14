
# Business service and dependancies

resource "pagerduty_business_service" "modernisation_platform" {
  name             = "Modernisation Platform"
  description      = "Hosting platform for non K8s workloads"
  point_of_contact = "#ask-modernisation-platform"
  team             = pagerduty_team.modernisation_platform.id
}

resource "pagerduty_service_dependency" "modernisation_platform_high_priority" {
    dependency {
        dependent_service {
            id = pagerduty_business_service.modernisation_platform.id
            type = "business_service"
        }
        supporting_service {
            id = pagerduty_service.high_priority.id
            type = "service"
        }
    }
}

resource "pagerduty_service_dependency" "modernisation_platform_low_priority" {
    dependency {
        dependent_service {
            id = pagerduty_business_service.modernisation_platform.id
            type = "business_service"
        }
        supporting_service {
            id = pagerduty_service.low_priority.id
            type = "service"
        }
    }
}
resource "pagerduty_service_dependency" "modernisation_platform_core_alerts" {
    dependency {
        dependent_service {
            id = pagerduty_business_service.modernisation_platform.id
            type = "business_service"
        }
        supporting_service {
            id = pagerduty_service.core_alerts.id
            type = "service"
        }
    }
}
resource "pagerduty_service_dependency" "modernisation_platform_on_call" {
    dependency {
        dependent_service {
            id = pagerduty_business_service.modernisation_platform.id
            type = "business_service"
        }
        supporting_service {
            id = pagerduty_service.contact_on_call.id
            type = "service"
        }
    }
}

resource "pagerduty_business_service" "integration_hub" {
  name             = "Integration Hub"
  description      = "Integration Hub services"
  point_of_contact = "#ask-integration-hub"
  team             = pagerduty_team.modernisation_platform.id
}

resource "pagerduty_business_service" "api_platform" {
  name = "API Platform"
}

resource "pagerduty_business_service" "events_platform" {
  name = "Events platform"
}

resource "pagerduty_business_service" "managed_file_transfer" {
  name = "Managed File Transfer"
}

resource "pagerduty_service_dependency" "integration_hub_api_platform" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.integration_hub.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_business_service.api_platform.id
      type = "business_service"
    }
  }
}

resource "pagerduty_service_dependency" "integration_hub_events_platform" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.integration_hub.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_business_service.events_platform.id
      type = "business_service"
    }
  }
}

resource "pagerduty_service_dependency" "integration_hub_managed_file_transfer" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.integration_hub.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_business_service.managed_file_transfer.id
      type = "business_service"
    }
  }
}

resource "pagerduty_service_dependency" "integration_hub_high_priority_alerts" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.managed_file_transfer.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_service.integration_hub_high_priority_alerts.id
      type = "service"
    }
  }
}

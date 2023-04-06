
# Business service and dependancies

resource "pagerduty_business_service" "modernisation_platform" {
  name             = "Modernisation Platform"
  description      = "Hosting platform for non K8s workloads"
  point_of_contact = "#ask-modernisation-platform"
  team             = pagerduty_team.modernisation_platform.id
}

resource "pagerduty_business_service" "modernisation_platform_networking" {
  name             = "Networking - Modernisation Platform"
  description      = "Networking"
  point_of_contact = "#ask-modernisation-platform"
  team             = pagerduty_team.modernisation_platform.id
}

resource "pagerduty_business_service" "modernisation_platform_security" {
  name             = "Security - Modernisation Platform"
  description      = "Security"
  point_of_contact = "#ask-modernisation-platform"
  team             = pagerduty_team.modernisation_platform.id
}

resource "pagerduty_business_service" "modernisation_platform_operations" {
  name             = "Operations - Modernisation Platform"
  description      = "Operations"
  point_of_contact = "#ask-modernisation-platform"
  team             = pagerduty_team.modernisation_platform.id
}

resource "pagerduty_service_dependency" "modernisation_platform_networking" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.modernisation_platform.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_business_service.modernisation_platform_networking.id
      type = "business_service"
    }
  }
}

resource "pagerduty_service_dependency" "modernisation_platform_security" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.modernisation_platform.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_business_service.modernisation_platform_security.id
      type = "business_service"
    }
  }
}

resource "pagerduty_service_dependency" "modernisation_platform_operations" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.modernisation_platform.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_business_service.modernisation_platform_operations.id
      type = "business_service"
    }
  }
}

resource "pagerduty_service_dependency" "modernisation_platform_core_alerts" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.modernisation_platform_security.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_service.core_alerts.id
      type = "service"
    }
  }
}
resource "pagerduty_service_dependency" "modernisation_platform_on_call" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.modernisation_platform_operations.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_service.contact_on_call.id
      type = "service"
    }
  }
}

resource "pagerduty_service_dependency" "modernisation_platform_ddos" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.modernisation_platform_security.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_service.ddos.id
      type = "service"
    }
  }
}

resource "pagerduty_service_dependency" "modernisation_platform_tgw" {
  dependency {
    dependent_service {
      id   = pagerduty_business_service.modernisation_platform_networking.id
      type = "business_service"
    }
    supporting_service {
      id   = pagerduty_service.tgw.id
      type = "service"
    }
  }
}

package main

expected :=
{
  "subnet_sets": {
    "garden-sandbox": {
      "general": {
        "cidr": "10.231.0.0/21",
        "accounts": [
          "sprinkler-development"
        ]
      }
    },
    "house-sandbox": {
      "general": {
        "cidr": "10.231.8.0/21",
        "accounts": [
          "cooker-development"
        ]
      }
    },
    "hmpps-preproduction": {
      "general": {
        "cidr": "10.27.0.0/21",
        "accounts": [
          "performance-hub-preproduction",
          "oasys-preproduction",
          "nomis-preproduction",
          "electronic-monitoring-data-preproduction",
          "ppud-preproduction",
          "delius-iaps-preproduction",
          "delius-jitbit-preproduction",
          "delius-mis-preproduction",
          "nomis-combined-reporting-preproduction",
          "nomis-data-hub-preproduction",
          "digital-prison-reporting-preproduction",
          "corporate-staff-rostering-preproduction",
          "planetfm-preproduction",
          "hmpps-oem-preproduction",
          "hmpps-domain-services-preproduction"
        ]
      }
    },
    "platforms-development": {
      "general": {
        "cidr": "10.26.16.0/21",
        "accounts": [
          "example-development",
          "data-platform-development",
          "data-platform-apps-and-tools-development",
          "observability-platform-development"
        ]
      }
    },
    "hmpps-development": {
      "general": {
        "cidr": "10.26.24.0/21",
        "accounts": [
          "performance-hub-development",
          "digital-prison-reporting-development",
          "electronic-monitoring-data-development",
          "equip-development",
          "ppud-development",
          "refer-monitor-development",
          "nomis-development",
          "oasys-development",
          "delius-iaps-development",
          "delius-jitbit-development",
          "delius-mis-development",
          "nomis-combined-reporting-development",
          "nomis-data-hub-development",
          "delius-core-development",
          "hmpps-intelligence-management-development",
          "corporate-staff-rostering-development",
          "planetfm-development",
          "hmpps-oem-development",
          "hmpps-domain-services-development"
        ]
      }
    },
    "platforms-test": {
      "general": {
        "cidr": "10.26.0.0/21",
        "accounts": [
          "data-platform-test",
          "testing-test"
        ]
      }
    },
    "hmpps-test": {
      "general": {
        "cidr": "10.26.8.0/21",
        "accounts": [
          "nomis-test",
          "oasys-test",
          "digital-prison-reporting-test",
          "delius-jitbit-test",
          "delius-mis-test",
          "nomis-combined-reporting-test",
          "nomis-data-hub-test",
          "corporate-staff-rostering-test",
          "planetfm-test",
          "hmpps-oem-test",
          "hmpps-domain-services-test",
          "delius-core-test"
        ]
      }
    },
    "cica-development": {
      "general": {
        "cidr": "10.26.32.0/21",
        "accounts": [
          "tariff-development",
          "cica-copilot-development"
        ]
      }
    },
    "hmpps-production": {
      "general": {
        "cidr": "10.27.8.0/21",
        "accounts": [
          "performance-hub-production",
          "ppud-production",
          "electronic-monitoring-data-production",
          "equip-production",
          "oasys-production",
          "nomis-production",
          "delius-iaps-production",
          "delius-jitbit-production",
          "delius-mis-production",
          "nomis-combined-reporting-production",
          "nomis-data-hub-production",
          "hmpps-intelligence-management-production",
          "corporate-staff-rostering-production",
          "planetfm-production",
          "hmpps-oem-production",
          "digital-prison-reporting-production",
          "hmpps-domain-services-production"
        ]
      }
    },
    "hmcts-development": {
      "general": {
        "cidr": "10.26.40.0/21",
        "accounts": [
          "xhibit-portal-development",
          "tipstaff-development",
          "tribunals-development",
          "dacp-development",
          "pra-registe-development",
          "ncas-development",
          "wardship-development"
        ]
      }
    },
    "hmcts-production": {
      "general": {
        "cidr": "10.27.16.0/21",
        "accounts": [
          "xhibit-portal-production",
          "tipstaff-production",
          "tribunals-production",
          "dacp-production",
          "pra-register-production",
          "ncas-production",
          "wardship-production"
        ]
      }
    },
    "hmcts-preproduction": {
      "general": {
        "cidr": "10.27.24.0/21",
        "accounts": [
          "xhibit-portal-preproduction",
          "tipstaff-preproduction",
          "tribunals-preproduction",
          "dacp-preproduction",
          "pra-register-preproduction",
          "ncas-preproduction",
          "wardship-preproduction"
        ]
      }
    },
    "hq-development": {
      "general": {
        "cidr": "10.26.48.0/21",
        "accounts": [
          "cdpt-chaps-development",
          "cdpt-ifs-development",
          "cortex-xsiam-development",
          "data-and-insights-wepi-development",
        ]
      }
    },
    "hq-test": {
      "general": {
        "cidr": "10.26.120.0/21",
        "accounts": [
          "threat-and-vulnerability-mgmt-production"
        ]
      }
    },
    "hq-production": {
      "general": {
        "cidr": "10.27.32.0/21",
        "accounts": [
          "cdpt-chaps-production",
          "cdpt-ifs-production",
          "cortex-xsiam-production",
          "data-and-insights-wepi-production",
        ]
      }
    },
    "laa-development": {
      "general": {
        "cidr": "10.26.56.0/21",
        "accounts": [
          "apex-development",
          "ccms-ebs-development",
          "ccms-ebs-upgrade-development",
          "laa-ccms-infra-azure-ad-sso",
          "laa-oem-development",
          "maat-development",
          "maatdb-development",
          "mlra-development",
          "oas-development",
          "portal-development",
          "mojfin-development"
        ]
      }
    },
    "opg-development": {
      "general": {
        "cidr": "10.26.72.0/21",
        "accounts": [
        ]
      }
    },
    "opg-test": {
      "general": {
        "cidr": "10.26.64.0/21",
        "accounts": [
        ]
      }
    },
    "cjse-development": {
      "general": {
        "cidr": "10.26.80.0/21",
        "accounts": [
        ]
      }
    },
    "cjse-test": {
      "general": {
        "cidr": "10.26.88.0/21",
        "accounts": [
        ]
      }
    },
    "laa-test": {
      "general": {
        "cidr": "10.26.96.0/21",
        "accounts": [
          "apex-test",
          "eric-test",
          "mlra-test",
          "ccms-ebs-test",
          "laa-oem-test",
          "maat-test",
          "oas-test",
          "portal-test",
          "mojfin-test"
        ]
      }
    },
    "hmcts-test": {
      "general": {
        "cidr": "10.26.104.0/21",
        "accounts": [
        ]
      }
    },
    "cica-test": {
      "general": {
        "cidr": "10.26.112.0/21",
        "accounts": [
        ]
      }
    },
    "hq-preproduction": {
      "general": {
        "cidr": "10.27.40.0/21",
        "accounts": ["data-and-insights-wepi-preproduction",
                     "cdpt-chaps-preproduction",
                     "cdpt-ifs-preproduction"
        ]
      }
    },
    "opg-production": {
      "general": {
        "cidr": "10.27.48.0/21",
        "accounts": [
        ]
      }
    },
    "opg-preproduction": {
      "general": {
        "cidr": "10.27.56.0/21",
        "accounts": [
        ]
      }
    },
    "laa-production": {
      "general": {
        "cidr": "10.27.64.0/21",
        "accounts": [
          "apex-production",
          "eric-production",
          "mlra-production",
          "ccms-ebs-production",
          "maat-production",
          "oas-production",
          "portal-production",
          "laa-oem-production",
          "mojfin-production"
        ]
      }
    },
    "laa-preproduction": {
      "general": {
        "cidr": "10.27.72.0/21",
        "accounts": [
          "apex-preproduction",
          "mlra-preproduction",
          "ccms-ebs-preproduction",
          "maat-preproduction",
          "oas-preproduction",
          "portal-preproduction",
          "laa-oem-preproduction"
        ]
      }
    },
    "cica-production": {
      "general": {
        "cidr": "10.27.80.0/21",
        "accounts": [
        ]
      }
    },
    "cica-preproduction": {
      "general": {
        "cidr": "10.27.88.0/21",
        "accounts": [
        ]
      }
    },
    "platforms-production": {
      "general": {
        "cidr": "10.27.96.0/21",
        "accounts": [
          "data-platform-production",
          "long-term-storage-production",
          "data-platform-apps-and-tools-production",
          "observability-platform-production"
        ]
      }
    },
    "platforms-preproduction": {
      "general": {
        "cidr": "10.27.104.0/21",
        "accounts": [
          "data-platform-preproduction"
        ]
      }
    },
    "cjse-production": {
      "general": {
        "cidr": "10.27.112.0/21",
        "accounts": [
        ]
      }
    },
    "cjse-preproduction": {
      "general": {
        "cidr": "10.27.120.0/21",
        "accounts": [
        ]
      }
    }
  }
}

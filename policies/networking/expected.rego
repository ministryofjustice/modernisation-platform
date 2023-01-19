package main

expected =
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
          "delius-iaps-preproduction",
          "delius-jitbit-preproduction"
        ]
      }
    },
    "platforms-development": {
      "general": {
        "cidr": "10.26.16.0/21",
        "accounts": [
          "example-development"
        ]
      }
    },
    "hmpps-development": {
      "general": {
        "cidr": "10.26.24.0/21",
        "accounts": [
          "performance-hub-development",
          "digital-prison-reporting-development",
          "equip-development",
          "ppud-development",
          "refer-monitor-development",
          "nomis-development",
          "oasys-development",
          "delius-iaps-development",
          "delius-jitbit-development"
        ]
      }
    },
    "platforms-test": {
      "general": {
        "cidr": "10.26.0.0/21",
        "accounts": [
          "testing-test"
        ]
      }
    },
    "hmpps-test": {
      "general": {
        "cidr": "10.26.8.0/21",
        "accounts": [
          "nomis-test",
          "oasys-test"
        ]
      }
    },
    "cica-development": {
      "general": {
        "cidr": "10.26.32.0/21",
        "accounts": [
          "tariff-development"
        ]
      }
    },
    "hmpps-production": {
      "general": {
        "cidr": "10.27.8.0/21",
        "accounts": [
          "performance-hub-production",
          "ppud-production",
          "equip-production",
          "oasys-production",
          "nomis-production",
          "delius-iaps-production",
          "delius-jitbit-production"
        ]
      }
    },
    "hmcts-development": {
      "general": {
        "cidr": "10.26.40.0/21",
        "accounts": [
          "xhibit-portal-development"
        ]
      }
    },
    "hmcts-production": {
      "general": {
        "cidr": "10.27.16.0/21",
        "accounts": [
          "xhibit-portal-production"
        ]
      }
    },
    "hmcts-preproduction": {
      "general": {
        "cidr": "10.27.24.0/21",
        "accounts": [
          "xhibit-portal-preproduction"
        ]
      }
    },
    "hq-development": {
      "general": {
        "cidr": "10.26.48.0/21",
        "accounts": [
          "data-and-insights-wepi-development"
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
          "data-and-insights-wepi-production"
        ]
      }
    },
    "laa-development": {
      "general": {
        "cidr": "10.26.56.0/21",
        "accounts": [
          "apex-development",
          "ccms-ebs-development",
          "maatdb-development",
          "mlra-development",
          "oas-development"
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
          "mlra-test",
          "ccms-ebs-test"
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
        "accounts": ["data-and-insights-wepi-preproduction"]
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
          "mlra-production",
          "ccms-ebs-production"
        ]
      }
    },
    "laa-preproduction": {
      "general": {
        "cidr": "10.27.72.0/21",
        "accounts": [
          "mlra-preproduction",
          "ccms-ebs-preproduction"
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
          "long-term-storage-production"
        ]
      }
    },
    "platforms-preproduction": {
      "general": {
        "cidr": "10.27.104.0/21",
        "accounts": [
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

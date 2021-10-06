package main

expected =
  {
  "transit_gateway": {
    "garden-development": "10.233.0.0/26",
    "house-development": "10.233.0.64/26",
    "garden-production": "10.233.0.128/26",
    "house-production": "10.233.0.192/26",
    "hmpps-preproduction": "10.233.1.0/26",
    "platforms-development": "10.233.1.64/26",
    "hmpps-development": "10.233.1.128/26",
    "platforms-test": "10.233.1.192/26",
    "hmpps-test": "10.233.2.0/26",
    "cica-development": "10.233.2.64/26",
    "hmpps-production": "10.233.2.128/26"
  },
  "protected": {
    "garden-development": "10.238.0.0/23",
    "house-development": "10.238.2.0/23",
    "garden-production": "10.238.4.0/23",
    "house-production": "10.238.6.0/23",
    "hmpps-preproduction": "10.238.8.0/23",
    "platforms-development": "10.238.10.0/23",
    "hmpps-development": "10.238.12.0/23",
    "platforms-test": "10.238.14.0/23",
    "hmpps-test": "10.238.16.0/23",
    "cica-development": "10.238.18.0/23",
    "hmpps-production": "10.238.20.0/23"
  },
  "subnet_sets": {
    "garden-development": {
      "general": {
        "cidr": "10.234.0.0/21",
        "accounts": [
          "sprinkler-development",
          "bench-development"
        ]
      },
      "patio": {
        "cidr": "10.234.8.0/21",
        "accounts": [
          "heater-development"
        ]
      }
    },
    "house-development": {
      "general": {
        "cidr": "10.234.16.0/21",
        "accounts": [
          "cooker-development"
        ]
      }
    },
    "garden-production": {
      "general": {
        "cidr": "10.237.0.0/21",
        "accounts": [
          "sprinkler-production",
          "bench-production"
        ]
      },
      "patio": {
        "cidr": "10.237.8.0/21",
        "accounts": [
          "heater-production"
        ]
      }
    },
    "house-production": {
      "general": {
        "cidr": "10.237.16.0/21",
        "accounts": [
          "cooker-production"
        ]
      }
    },
    "hmpps-preproduction": {
      "general": {
        "cidr": "10.236.0.0/21",
        "accounts": [
          "performance-hub-preproduction"
        ]
      }
    },
    "platforms-development": {
      "general": {
        "cidr": "10.234.24.0/21",
        "accounts": [
          "ops-engineering-development"
        ]
      }
    },
    "hmpps-development": {
      "general": {
        "cidr": "10.234.32.0/21",
        "accounts": [
          "performance-hub-development"
        ]
      }
    },
    "platforms-test": {
      "general": {
        "cidr": "10.235.0.0/21",
        "accounts": [
          "testing-test"
        ]
      }
    },
    "hmpps-test": {
      "nomis": {
        "cidr": "10.235.8.0/21",
        "accounts": [
          "nomis-test"
        ]
      }
    },
    "cica-development": {
      "general": {
        "cidr": "10.234.40.0/21",
        "accounts": [
          "tariff-development"
        ]
      }
    },
    "hmpps-production": {
      "general": {
        "cidr": "10.237.24.0/21",
        "accounts": [
          "performance-hub-production"
        ]
      }
    },
    "hmcts-development": {
      "general": {
        "cidr": "10.234.48.0/21",
        "accounts": [
          "xhibit-portal-development"
        ]
      }
    },
    "hmcts-production": {
      "general": {
        "cidr": "10.237.32.0/21",
        "accounts": [
          "xhibit-portal-production"
        ]
      }
    }
  }
}

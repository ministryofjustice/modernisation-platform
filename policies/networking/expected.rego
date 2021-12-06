package main

expected =
  {
  "transit_gateway": {
    "garden-sandbox": "10.233.0.0/26",
    "house-sandbox": "10.233.0.64/26",
    "hmpps-preproduction": "10.233.1.0/26",
    "platforms-development": "10.233.1.64/26",
    "hmpps-development": "10.233.1.128/26",
    "platforms-test": "10.233.1.192/26",
    "hmpps-test": "10.233.2.0/26",
    "cica-development": "10.233.2.64/26",
    "hmpps-production": "10.233.2.128/26",
    "hmcts-development": "10.233.2.192/26",
    "hmcts-production": "10.233.3.0/26"
  },
  "protected": {
    "garden-sandbox": "10.238.0.0/23",
    "house-sandbox": "10.238.2.0/23",
    "hmpps-preproduction": "10.238.8.0/23",
    "platforms-development": "10.238.10.0/23",
    "hmpps-development": "10.238.12.0/23",
    "platforms-test": "10.238.14.0/23",
    "hmpps-test": "10.238.16.0/23",
    "cica-development": "10.238.18.0/23",
    "hmpps-production": "10.238.20.0/23",
    "hmcts-development": "10.238.22.0/23",
    "hmcts-production": "10.238.24.0/23"
  },
  "subnet_sets": {
    "garden-sandbox": {
      "general": {
        "cidr": "10.239.0.0/21",
        "accounts": [
          "sprinkler-development"
        ]
      }
    },
    "house-sandbox": {
      "general": {
        "cidr": "10.239.8.0/21",
        "accounts": [
          "cooker-development"
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
        "cidr": "10.26.16.0/21",
        "accounts": []
      }
    },
    "hmpps-development": {
      "general": {
        "cidr": "10.26.24.0/21",
        "accounts": [
          "performance-hub-development"
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
          "nomis-test"
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
        "cidr": "10.237.24.0/21",
        "accounts": [
          "performance-hub-production"
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
        "cidr": "10.237.32.0/21",
        "accounts": [
          "xhibit-portal-production"
        ]
      }
    }
  }
}

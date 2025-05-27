package policies.networking

import rego.v1

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
    "cica-development": {
      "general": {
        "cidr": "10.26.32.0/21",
        "accounts": [
          "cica-copilot-development",
          "cica-data-extraction-development",
          "cica-tariff-development"
        ]
      }
    },
    "cica-test": {
      "general": {
        "cidr": "10.26.112.0/21",
        "accounts": [
          "cica-tariff-test"
        ]
      }
    },
    "cica-preproduction": {
      "general": {
        "cidr": "10.27.88.0/21",
        "accounts": [
          "cica-tariff-preproduction"
        ]
      }
    },
    "cica-production": {
      "general": {
        "cidr": "10.27.80.0/21",
        "accounts": [
          "cica-tariff-production"
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
    "cjse-preproduction": {
      "general": {
        "cidr": "10.27.120.0/21",
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
    "hmcts-test": {
      "general": {
        "cidr": "10.26.104.0/21",
        "accounts": [
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
          "delius-alfresco-development",
          "delius-iaps-development",
          "delius-jitbit-development",
          "delius-mis-development",
          "nomis-combined-reporting-development",
          "nomis-data-hub-development",
          "delius-core-development",
          "corporate-staff-rostering-development",
          "planetfm-development",
          "hmpps-oem-development",
          "hmpps-domain-services-development",
          "oasys-national-reporting-development"
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
          "delius-alfresco-test",
          "delius-jitbit-test",
          "nomis-combined-reporting-test",
          "nomis-data-hub-test",
          "corporate-staff-rostering-test",
          "planetfm-test",
          "hmpps-oem-test",
          "hmpps-domain-services-test",
          "delius-core-test",
          "oasys-national-reporting-test"
        ]
      }
    },
    "hmpps-preproduction": {
      "general": {
        "cidr": "10.27.0.0/21",
        "accounts": [
          "corporate-staff-rostering-preproduction",
          "delius-alfresco-preproduction",
          "delius-core-preproduction",
          "delius-iaps-preproduction",
          "delius-jitbit-preproduction",
          "delius-mis-preproduction",
          "digital-prison-reporting-preproduction",
          "electronic-monitoring-data-preproduction",
          "hmpps-domain-services-preproduction",
          "hmpps-oem-preproduction",
          "nomis-preproduction",
          "nomis-combined-reporting-preproduction",
          "nomis-data-hub-preproduction",
          "oasys-preproduction",
          "oasys-national-reporting-preproduction",
          "performance-hub-preproduction",
          "planetfm-preproduction",
          "ppud-preproduction"
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
          "delius-alfresco-production",
          "delius-iaps-production",
          "delius-jitbit-production",
          "delius-mis-production",
          "nomis-combined-reporting-production",
          "nomis-data-hub-production",
          "corporate-staff-rostering-production",
          "planetfm-production",
          "hmpps-oem-production",
          "digital-prison-reporting-production",
          "hmpps-domain-services-production",
          "delius-core-production",
          "oasys-national-reporting-production"
        ]
      }
    },
    "hq-development": {
      "general": {
        "cidr": "10.26.48.0/21",
        "accounts": [
          "cdpt-chaps-development",
          "cdpt-ifs-development"
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
    "hq-preproduction": {
      "general": {
        "cidr": "10.27.40.0/21",
        "accounts": [
          "cdpt-chaps-preproduction",
          "cdpt-ifs-preproduction"
        ]
      }
    },
    "hq-production": {
      "general": {
        "cidr": "10.27.32.0/21",
        "accounts": [
          "cdpt-chaps-production",
          "cdpt-ifs-production"
        ]
      }
    },
    "laa-development": {
      "general": {
        "cidr": "10.26.56.0/21",
        "accounts": [
          "apex-development",
          "bacway-development",
          "ccms-ebs-development",
          "ccms-ebs-upgrade-development",
          "ccms-edrms-development",
          "contract-work-administration-development",
          "corporate-information-system-development",
          "edw-development",
          "laa-ccms-infra-azure-ad-sso",
          "laa-ccms-soa-development",
          "laa-cwa-development",
          "laa-mail-relay-development",
          "laa-oem-development",
          "laa-stabilisation-cdc-poc-development",
          "maat-development",
          "maatdb-development",
          "mlra-development",
          "oas-development",
          "portal-development",
          "mojfin-development"
        ]
      }
    },
    "laa-test": {
      "general": {
        "cidr": "10.26.96.0/21",
        "accounts": [
          "apex-test",
          "ccms-ebs-test",
          "ccms-ebs-upgrade-test",
          "ccms-edrms-test",
          "contract-work-administration-test",
          "corporate-information-system-test",
          "edw-test",
          "laa-ccms-soa-test",
          "laa-cwa-test",
          "laa-mail-relay-test",
          "laa-oem-test",
          "maat-test",
          "maatdb-test",
          "mlra-test",
          "mojfin-test",
          "oas-test",
          "portal-test"
        ]
      }
    },
    "laa-preproduction": {
      "general": {
        "cidr": "10.27.72.0/21",
        "accounts": [
          "apex-preproduction",
          "bacway-preproduction",
          "ccms-ebs-preproduction",
          "ccms-edrms-preproduction",
          "contract-work-administration-preproduction",
          "corporate-information-system-preproduction",
          "edw-preproduction",
          "laa-ccms-soa-preproduction",
          "laa-cwa-preproduction",
          "laa-mail-relay-preproduction",
          "laa-oem-preproduction",
          "maat-preproduction",
          "maatdb-preproduction",
          "mlra-preproduction",
          "mojfin-preproduction",
          "oas-preproduction",
          "portal-preproduction"
        ]
      }
    },
    "laa-production": {
      "general": {
        "cidr": "10.27.64.0/21",
        "accounts": [
          "apex-production",
          "bacway-production",
          "ccms-ebs-production",
          "ccms-edrms-production",
          "contract-work-administration-production",
          "corporate-information-system-production",
          "edw-production",
          "laa-ccms-soa-production",
          "laa-cwa-production",
          "laa-mail-relay-production",
          "laa-oem-production",
          "maat-production",
          "maatdb-production",
          "mlra-production",
          "mojfin-production",
          "oas-production",
          "portal-production"
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
    "opg-preproduction": {
      "general": {
        "cidr": "10.27.56.0/21",
        "accounts": [
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
    "platforms-development": {
      "general": {
        "cidr": "10.26.16.0/21",
        "accounts": [
          "analytical-platform-ingestion-development",
          "coat-development",
          "example-development",
          "data-platform-development",
          "observability-platform-development",
          "operations-engineering-development",
          "panda-cyber-appsec-lab-development"
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
    "platforms-preproduction": {
      "general": {
        "cidr": "10.27.104.0/21",
        "accounts": [
          "data-platform-preproduction"
        ]
      }
    },
    "platforms-production": {
      "general": {
        "cidr": "10.27.96.0/21",
        "accounts": [
          "analytical-platform-common-production",
          "analytical-platform-ingestion-production",
          "coat-production",
          "data-platform-production",
          "long-term-storage-production",
          "observability-platform-production"
        ]
      }
    },
    "yjb-development": {
      "general": {
        "cidr": "10.26.144.0/21",
        "accounts": [
          "youth-justice-app-framework-development"
        ]
      }
    },
    "yjb-test": {
      "general": {
        "cidr": "10.26.152.0/21",
        "accounts": [
          "youth-justice-app-framework-test"
        ]
      }
    },
    "yjb-preproduction": {
      "general": {
        "cidr": "10.27.144.0/21",
        "accounts": [
        ]
      }
    },
    "yjb-production": {
      "general": {
        "cidr": "10.27.152.0/21",
        "accounts": [
        ]
      }
    }
  }
}

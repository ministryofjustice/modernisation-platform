package policies.environments

import rego.v1

test_empty_file if {
  deny["`example.json` is an empty file"] with input as { "filename": "example.json" }
}

test_no_environments if {
  deny["`example.json` is missing the `environments` key"] with input as { "filename": "example.json" }
}

test_empty_environments if {
  deny["`example.json` has no environments"] with input as { "filename": "example.json", "environments": [] }
}

test_no_tags if {
  deny["`example.json` is missing the `tags` key"] with input as { "filename": "example.json" }
}

test_no_tags_application if {
  deny["`example.json` is missing the `application` tag"] with input as { "filename": "example.json", "tags": {} }
  deny["`example.json` is missing the `business-unit` tag"] with input as { "filename": "example.json", "tags": {} }
  deny["`example.json` is missing the `owner` tag"] with input as { "filename": "example.json", "tags": {} }
}

test_empty_values if {
  deny["`example.json` is missing the `application` tag"] with input as { "filename": "example.json", "tags": {"application": ""} }
  deny["`example.json` is missing the `business-unit` tag"] with input as { "filename": "example.json", "tags": {"business-unit": ""} }
  deny["`example.json` is missing the `owner` tag"] with input as { "filename": "example.json", "tags": {"owner": ""} }
}

test_unexpected_business_units if {
  deny["`example.json` uses an unexpected business-unit: got `incorrect-business-unit`, expected one of: HQ, HMPPS, OPG, LAA, HMCTS, CICA, Platforms, CJSE"] with input as { "filename": "example.json", "tags": { "business-unit": "incorrect-business-unit" } }
}

test_business_units_length if {
  deny["`example.json` Business unit name does not meet requirements"] with input as { "filename": "example.json", "tags": { "business-unit": "example-this-is-too-long-for-a-business-unit" } }
}

test_business_units_character if {
  deny["`example.json` Business unit name does not meet requirements"] with input as { "filename": "example.json", "tags": { "business-unit": "Platforms4" } }
}

test_unexpected_access if {
  deny["`example.json` uses an unexpected access level: got `incorrect-access`, expected one of: administrator, data-engineer, developer, instance-access, instance-management, migration, mwaa-user, read-only, reporting-operations, sandbox, security-audit, view-only, powerbi-user, fleet-manager, quicksight-admin"] with input as { "filename": "example.json", "environments": [{"access": [{"level": "incorrect-access"}]}]}
}

test_unexpected_access_assignment if {
  deny["`example.json` uses `powerbi-user` access level but is not an analytical platform or sprinkler account"] with input as { "filename": "example.json", "environments": [{"access": [{"level": "powerbi-user"}]}]}
}

test_unexpected_nuke if {
  deny["`example.json` uses an unexpected nuke value: got `incorrect-value`, expected one of: include, exclude, rebuild"] with input as { "filename": "example.json", "environments": [{"access": [{"nuke": "incorrect-value"}]}]}
}

test_invalid_email if {
  deny["`example.json` infrastructure-support value is not a valid email address"] with input as { "filename": "example.json", "tags": { "infrastructure-support": "not-a-valid-email-address" } }
}

test_critical_national_infastructure_empty if {
    deny["`example.json` is missing the `critical-national-infrastructure` field"] with input as { 
        "filename": "example.json",
        "tags": {}
    }
}

test_critical_national_infrastructure_invalid if {
    test_input := {
        "filename": "example.json",
        "tags": {
            "critical-national-infrastructure": "Maybe"
        }
    }
    deny_result := deny with input as test_input
    count(deny_result) > 0
    deny_message := sprintf("`%v` has invalid `critical-national-infrastructure` value: got `%v`, expected a boolean (true or false)", [test_input.filename, test_input.tags["critical-national-infrastructure"]])
    deny_message in deny_result
}
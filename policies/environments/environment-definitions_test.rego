package main

test_empty_file {
  deny["`example.json` is an empty file"] with input as { "filename": "example.json" }
}

test_no_environments {
  deny["`example.json` is missing the `environments` key"] with input as { "filename": "example.json" }
}

test_empty_environments {
  deny["`example.json` has no environments"] with input as { "filename": "example.json", "environments": [] }
}

test_no_tags {
  deny["`example.json` is missing the `tags` key"] with input as { "filename": "example.json" }
}

test_no_tags_application {
  deny["`example.json` is missing the `application` tag"] with input as { "filename": "example.json", "tags": {} }
  deny["`example.json` is missing the `business-unit` tag"] with input as { "filename": "example.json", "tags": {} }
  deny["`example.json` is missing the `owner` tag"] with input as { "filename": "example.json", "tags": {} }
}

test_empty_values {
  deny["`example.json` is missing the `application` tag"] with input as { "filename": "example.json", "tags": {"application": ""} }
  deny["`example.json` is missing the `business-unit` tag"] with input as { "filename": "example.json", "tags": {"business-unit": ""} }
  deny["`example.json` is missing the `owner` tag"] with input as { "filename": "example.json", "tags": {"owner": ""} }
}

test_unexpected_business_units {
  deny["`example.json` uses an unexpected business-unit: got `incorrect-business-unit`, expected one of: HQ, HMPPS, OPG, LAA, HMCTS, CICA, Platforms, CJSE"] with input as { "filename": "example.json", "tags": { "business-unit": "incorrect-business-unit" } }
}

test_business_units_length{
  deny["`example.json` Business unit name does not meet requirements"] with input as { "filename": "example.json", "tags": { "business-unit": "example-this-is-too-long-for-a-business-unit" } }
}

test_business_units_character{
  deny["`example.json` Business unit name does not meet requirements"] with input as { "filename": "example.json", "tags": { "business-unit": "Platforms4" } }
}

test_unexpected_access {
  deny["`example.json` uses an unexpected access level: got `incorrect-access`, expected one of: view-only, developer, sandbox, administrator, migration, instance-management, read-only, security-audit, data-engineer, reporting-operations, mwaa-user, powerbi-user"] with input as { "filename": "example.json", "environments": [{"access": [{"level": "incorrect-access"}]}]}
}

test_unexpected_access_assignment {
  deny["`example.json` uses an unexpected access assignment: got `powerbi-user`, but `example` is not an analytical platform or sprinkler account"] with input as { "filename": "example.json", "environments": [{"access": [{"level": "powerbi-user"}]}]}
}

test_unexpected_nuke {
  deny["`example.json` uses an unexpected nuke value: got `incorrect-value`, expected one of: include, exclude, rebuild"] with input as { "filename": "example.json", "environments": [{"access": [{"nuke": "incorrect-value"}]}]}
}

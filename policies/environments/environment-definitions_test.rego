package main

test-empty-file if {
  deny["`example.json` is an empty file"] with input as { "filename": "example.json" }
}

test-no-environments if {
  deny["`example.json` is missing the `environments` key"] with input as { "filename": "example.json" }
}

test-empty-environments if {
  deny["`example.json` has no environments"] with input as { "filename": "example.json", "environments": [] }
}

test-no-tags if {
  deny["`example.json` is missing the `tags` key"] with input as { "filename": "example.json" }
}

test-no-tags-application if {
  deny["`example.json` is missing the `application` tag"] with input as { "filename": "example.json", "tags": {} }
  deny["`example.json` is missing the `business-unit` tag"] with input as { "filename": "example.json", "tags": {} }
  deny["`example.json` is missing the `owner` tag"] with input as { "filename": "example.json", "tags": {} }
}

test-empty-values if {
  deny["`example.json` is missing the `application` tag"] with input as { "filename": "example.json", "tags": {"application": ""} }
  deny["`example.json` is missing the `business-unit` tag"] with input as { "filename": "example.json", "tags": {"business-unit": ""} }
  deny["`example.json` is missing the `owner` tag"] with input as { "filename": "example.json", "tags": {"owner": ""} }
}

test-unexpected-business-units if {
  deny["`example.json` uses an unexpected business-unit: got `incorrect-business-unit`, expected one of: HQ, HMPPS, OPG, LAA, HMCTS, CICA, Platforms, CJSE"] with input as { "filename": "example.json", "tags": { "business-unit": "incorrect-business-unit" } }
}

test-business-units-length if {
  deny["`example.json` Business unit name does not meet requirements"] with input as { "filename": "example.json", "tags": { "business-unit": "example-this-is-too-long-for-a-business-unit" } }
}

test-business-units-character if {
  deny["`example.json` Business unit name does not meet requirements"] with input as { "filename": "example.json", "tags": { "business-unit": "Platforms4" } }
}

test-unexpected-access if {
  deny["`example.json` uses an unexpected access level: got `incorrect-access`, expected one of: view-only, developer, sandbox, administrator, migration, instance-management, read-only, security-audit, data-engineer, reporting-operations, mwaa-user, powerbi-user"] with input as { "filename": "example.json", "environments": [{"access": [{"level": "incorrect-access"}]}]}
}

test-unexpected-access-assignment if {
  deny["`example.json` uses an unexpected access assignment: got `powerbi-user`, but `example` is not an analytical platform or sprinkler account"] with input as { "filename": "example.json", "environments": [{"access": [{"level": "powerbi-user"}]}]}
}

test-unexpected-nuke if {
  deny["`example.json` uses an unexpected nuke value: got `incorrect-value`, expected one of: include, exclude, rebuild"] with input as { "filename": "example.json", "environments": [{"access": [{"nuke": "incorrect-value"}]}]}
}

package main

testEmptyFile if {
  deny["`example.json` is an empty file"] with input as { "filename": "example.json" }
}

testNoEnvironments if {
  deny["`example.json` is missing the `environments` key"] with input as { "filename": "example.json" }
}

testEmptyEnvironments if {
  deny["`example.json` has no environments"] with input as { "filename": "example.json", "environments": [] }
}

testNoTags if {
  deny["`example.json` is missing the `tags` key"] with input as { "filename": "example.json" }
}

testNoTagsApplication if {
  deny["`example.json` is missing the `application` tag"] with input as { "filename": "example.json", "tags": {} }
  deny["`example.json` is missing the `businessUnit` tag"] with input as { "filename": "example.json", "tags": {} }
  deny["`example.json` is missing the `owner` tag"] with input as { "filename": "example.json", "tags": {} }
}

testEmptyValues if {
  deny["`example.json` is missing the `application` tag"] with input as { "filename": "example.json", "tags": {"application": ""} }
  deny["`example.json` is missing the `businessUnit` tag"] with input as { "filename": "example.json", "tags": {"businessUnit": ""} }
  deny["`example.json` is missing the `owner` tag"] with input as { "filename": "example.json", "tags": {"owner": ""} }
}

testUnexpectedBusinessUnits if {
  deny["`example.json` uses an unexpected businessUnit: got `incorrectBusinessUnit`, expected one of: HQ, HMPPS, OPG, LAA, HMCTS, CICA, Platforms, CJSE"] with input as { "filename": "example.json", "tags": { "businessUnit": "incorrectBusinessUnit" } }
}

testBusinessUnitsLength if {
  deny["`example.json` Business unit name does not meet requirements"] with input as { "filename": "example.json", "tags": { "business-unit": "example-this-is-too-long-for-a-business-unit" } }
}

testBusinessUnitsCharacter if {
  deny["`example.json` Business unit name does not meet requirements"] with input as { "filename": "example.json", "tags": { "businessUnit": "Platforms4" } }
}

testUnexpectedAccess if {
  deny["`example.json` uses an unexpected access level: got `incorrectAccess`, expected one of: view-only, developer, sandbox, administrator, migration, instance-management, read-only, security-audit, data-engineer, reporting-operations, mwaa-user, powerbi-user"] with input as { "filename": "example.json", "environments": [{"access": [{"level": "incorrectAccess"}]}]}
}

testUnexpectedAccessAssignment if {
  deny["`example.json` uses an unexpected access assignment: got `powerbiUser`, but `example` is not an analytical platform or sprinkler account"] with input as { "filename": "example.json", "environments": [{"access": [{"level": "powerbiUser"}]}]}
}

testUnexpectedNuke if {
  deny["`example.json` uses an unexpected nuke value: got `incorrectValue`, expected one of: include, exclude, rebuild"] with input as { "filename": "example.json", "environments": [{"access": [{"nuke": "incorrectValue"}]}]}
}
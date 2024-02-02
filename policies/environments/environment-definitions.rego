package main

import future.keywords.in

allowed_business_units := [
  "HQ",
  "HMPPS",
  "OPG",
  "LAA",
  "HMCTS",
  "CICA",
  "Platforms",
  "CJSE"
]

allowed_access := [
  "administrator",
  "data-engineer",
  "developer",
  "instance-management",
  "migration",
  "mwaa-user",
  "read-only",
  "reporting-operations",
  "sandbox",
  "security-audit",
  "view-only",
  "powerbi-user"
]

allowed_nuke := [
  "include",
  "exclude",
  "rebuild"
]

deny[msg] {
  without_filename := object.remove(input, ["filename"])

  not count(without_filename) != 0

  msg := sprintf("`%v` is an empty file", [input.filename])
}

deny[msg] {
  not has_field(input, "environments")
  msg := sprintf("`%v` is missing the `environments` key", [input.filename])
}

deny[msg] {
  count(input.environments) == 0
  msg := sprintf("`%v` has no environments", [input.filename])
}

deny[msg] {
  environment := input.environments[_]
  not has_field(environment, "name")
  msg := sprintf("`%v` has an environment that is missing a `name` value", [input.filename])
}

deny[msg] {
  environment := input.environments[_]
  not has_field(environment, "access")
  msg := sprintf("`%v` has an environment that is missing a `access` value", [input.filename])
}

deny[msg] {
  not has_field(input, "tags")
  msg := sprintf("`%v` is missing the `tags` key", [input.filename])
}

deny[msg] {
  not has_field(input.tags, "application")
  msg := sprintf("`%v` is missing the `application` tag", [input.filename])
}

deny[msg] {
  not has_field(input.tags, "business-unit")
  msg := sprintf("`%v` is missing the `business-unit` tag", [input.filename])
}

deny[msg] {
  not input.tags["business-unit"] in allowed_business_units
  msg := sprintf("`%v` uses an unexpected business-unit: got `%v`, expected one of: %v", [input.filename, input.tags["business-unit"], concat(", ", allowed_business_units) ])
}

deny[msg] {
  not regex.match(`^[a-zA-Z-]{1,20}$`, input.tags["business-unit"])
  msg := sprintf("`%v` Business unit name does not meet requirements", [input.filename])
}

deny[msg] {
  not has_field(input.tags, "owner")
  msg := sprintf("`%v` is missing the `owner` tag", [input.filename])
}

deny[msg] {
  access:=input.environments[_].access[_].level
  not access in allowed_access
  msg := sprintf("`%v` uses an unexpected access level: got `%v`, expected one of: %v", [input.filename, access, concat(", ", allowed_access) ])
}

deny[msg] {
  nuke:=input.environments[_].access[_].nuke
  not nuke in allowed_nuke
  msg := sprintf("`%v` uses an unexpected nuke value: got `%v`, expected one of: %v", [input.filename, nuke, concat(", ", allowed_nuke) ])
}

deny[msg] {
  access := input.environments[_].access[_].level
  access == "powerbi-user"
  not startswith(input.filename, "environments/analytical-platform")
  not startswith(input.filename, "environments/sprinkler") # to allow testing
  msg := sprintf("`%v` uses `powerbi-user` access level but is not an analytical platform or sprinkler account", [input.filename])
}
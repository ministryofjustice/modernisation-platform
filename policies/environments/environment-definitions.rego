package main

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
  "view-only",
  "developer",
  "sandbox",
  "administrator",
  "migration",
  "instance-management",
  "read-only",
  "security-audit",
  "data-engineer",
  "reporting-operations",
  "mwaa-user"
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
  not array_contains(allowed_business_units, input.tags["business-unit"])
  msg := sprintf("`%v` uses an unexpected business-unit: got `%v`, expected one of: %v", [input.filename, input.tags["business-unit"], concat(", ", allowed_business_units) ])
}

deny[msg] {
  not regex.match("^[a-zA-Z-]{1,20}$", input.tags["business-unit"])
  msg := sprintf("`%v` Business unit name does not meet requirements", [input.filename])
}

deny[msg] {
  not has_field(input.tags, "owner")
  msg := sprintf("`%v` is missing the `owner` tag", [input.filename])
}

deny[msg] {
  access:=input.environments[_].access[_].level
  not array_contains(allowed_access, access)
  msg := sprintf("`%v` uses an unexpected access level: got `%v`, expected one of: %v", [input.filename, access, concat(", ", allowed_access) ])
}

deny[msg] {
  nuke:=input.environments[_].access[_].nuke
  not array_contains(allowed_nuke, nuke)
  msg := sprintf("`%v` uses an unexpected nuke value: got `%v`, expected one of: %v", [input.filename, nuke, concat(", ", allowed_nuke) ])
}

package policies.environments

import rego.v1

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
  "instance-access",
  "instance-management",
  "migration",
  "mwaa-user",
  "read-only",
  "reporting-operations",
  "sandbox",
  "security-audit",
  "view-only",
  "powerbi-user",
  "fleet-manager",
  "quicksight-admin"
]

allowed_nuke := [
  "include",
  "exclude",
  "rebuild"
]

deny contains msg if {
  without_filename := object.remove(input, ["filename"])

  not count(without_filename) != 0

  msg := sprintf("`%v` is an empty file", [input.filename])
}

deny contains msg if {
  not has_field(input, "environments")
  msg := sprintf("`%v` is missing the `environments` key", [input.filename])
}

deny contains msg if {
  count(input.environments) == 0
  msg := sprintf("`%v` has no environments", [input.filename])
}

deny contains msg if {
  environment := input.environments[_]
  not has_field(environment, "name")
  msg := sprintf("`%v` has an environment that is missing a `name` value", [input.filename])
}

deny contains msg if {
  environment := input.environments[_]
  not has_field(environment, "access")
  msg := sprintf("`%v` has an environment that is missing a `access` value", [input.filename])
}

deny contains msg if {
  not has_field(input, "tags")
  msg := sprintf("`%v` is missing the `tags` key", [input.filename])
}

deny contains msg if {
  not has_field(input.tags, "application")
  msg := sprintf("`%v` is missing the `application` tag", [input.filename])
}

deny contains msg if {
  not has_field(input.tags, "business-unit")
  msg := sprintf("`%v` is missing the `business-unit` tag", [input.filename])
}

deny contains msg if {
  not input.tags["business-unit"] in allowed_business_units
  msg := sprintf("`%v` uses an unexpected business-unit: got `%v`, expected one of: %v", [input.filename, input.tags["business-unit"], concat(", ", allowed_business_units) ])
}

deny contains msg if {
  not regex.match(`^[a-zA-Z-]{1,20}$`, input.tags["business-unit"])
  msg := sprintf("`%v` Business unit name does not meet requirements", [input.filename])
}

deny contains msg if {
  not has_field(input.tags, "owner")
  msg := sprintf("`%v` is missing the `owner` tag", [input.filename])
}

deny contains msg if {
  access:=input.environments[_].access[_].level
  not access in allowed_access
  msg := sprintf("`%v` uses an unexpected access level: got `%v`, expected one of: %v", [input.filename, access, concat(", ", allowed_access) ])
}

deny contains msg if {
  nuke:=input.environments[_].access[_].nuke
  not nuke in allowed_nuke
  msg := sprintf("`%v` uses an unexpected nuke value: got `%v`, expected one of: %v", [input.filename, nuke, concat(", ", allowed_nuke) ])
}

deny contains msg if {
  access := input.environments[_].access[_].level
  access == "powerbi-user"
  not startswith(input.filename, "environments/analytical-platform")
  not startswith(input.filename, "environments/sprinkler") # to allow testing
  msg := sprintf("`%v` uses `powerbi-user` access level but is not an analytical platform or sprinkler account", [input.filename])
}

deny contains msg if {
  not has_field(input, "github-oidc-team-repositories")
  msg := sprintf("`%v` is missing the `github-oidc-team-repositories` key", [input.filename])
}

deny contains msg if {
  not regex.match(`^\S+@\S+$`, input.tags["infrastructure-support"])
 msg := sprintf("`%v` infrastructure-support value is not a valid email address", [input.filename])
}

deny contains msg if {
  not has_field(input.tags, "critical-national-infrastructure")
  msg := sprintf("`%v` is missing the `critical-national-infrastructure` field", [input.filename])
}

deny contains msg if {
  not is_boolean(input.tags["critical-national-infrastructure"])
  msg := sprintf("`%v` has invalid `critical-national-infrastructure` value: got `%v`, expected a boolean (true or false)", [input.filename, input.tags["critical-national-infrastructure"]])
}
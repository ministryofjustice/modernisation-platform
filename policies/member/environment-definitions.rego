package policies.member

import rego.v1

allowed_environments := [
  "development",
  "test",
  "preproduction",
  "production",
  "nonlive",
  "live"
]

allowed_long_name_exceptions := [
  "analytical-platform-next-poc-producer"
]

valid_filename if {
  regex.match(`^environments\/[a-z0-9-]{1,36}\.json$`, input.filename)
}

valid_filename if {
  some name in allowed_long_name_exceptions
  regex.match(sprintf(`^environments\/%s\.json$`, [name]), input.filename)
}

deny contains msg if {
  some environment in input.environments
  not environment.name in allowed_environments
  msg := sprintf("`%v` uses an unexpected environment: got `%v`, expected one of: %v", [input.filename, environment.name, concat(", ", allowed_environments) ])
}

deny contains msg if {
  not valid_filename
  msg := sprintf("`%v` filename does not meet requirements", [input.filename])
}

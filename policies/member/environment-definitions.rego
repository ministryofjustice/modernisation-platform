package policies.member

import rego.v1

allowed_environments := [
  "development",
  "test",
  "preproduction",
  "production"
]

deny contains msg if {
  some environment in input.environments
  not environment.name in allowed_environments
  msg := sprintf("`%v` uses an unexpected environment: got `%v`, expected one of: %v", [input.filename, environment.name, concat(", ", allowed_environments) ])
}

deny contains msg if {
  not regex.match(`^environments\/[a-z-]{1,30}\.json$`,input.filename)
  msg := sprintf("`%v` filename does not meet requirements", [input.filename])
}

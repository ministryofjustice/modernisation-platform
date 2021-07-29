package main

allowed_environments := [
  "development",
  "test",
  "preproduction",
  "production"
]

deny[msg] {
  not array_contains(allowed_environments, input.environments[i].name)
  msg := sprintf("`%v` uses an unexpected environment: got `%v`, expected one of: %v", [input.filename, input.environments[i].name, concat(", ", allowed_environments) ])
}

deny[msg] {
  not regex.match("^environments\\/[a-z-]{1,30}\\.json$",input.filename)
  msg := sprintf("`%v` filename does not meet requirements", [input.filename])
}

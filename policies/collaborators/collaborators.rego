package main

import future.keywords.in

allowed_access := [
  "read-only",
  "developer",
  "security-audit",
  "sandbox",
  "migration",
  "instance-management",
  "fleet-manager"
]

deny[msg] {
  without_filename := object.remove(input, ["filename"])

  not count(without_filename) != 0

  msg := sprintf("`%v` is an empty file", [input.filename])
}

deny[msg] {
  not has_field(input, "users")
  msg := sprintf("`%v` is missing the `users` key", [input.filename])
}

deny[msg] {
  users := input.users[_]
  not has_field(users, "username")
  msg := sprintf("`%v` is missing the `username` key", [input.filename])
}

deny[msg] {
  users := input.users[_]
  not has_field(users, "github-username")
  msg := sprintf("`%v` is missing the `github-username` key", [input.filename])
}

deny[msg] {
  users := input.users[_]
  not has_field(users, "accounts")
  msg := sprintf("`%v` is missing the `accounts` key", [input.filename])
}

deny[msg] {
  accounts := input.users[_].accounts[_]
  not has_field(accounts, "account-name")
  msg := sprintf("`%v` is missing the `account-name` key", [input.filename])
}

deny[msg] {
  accounts := input.users[_].accounts[_]
  not has_field(accounts, "access")
  msg := sprintf("`%v` is missing the `access` key", [input.filename])
}

deny[msg] {
  accounts := input.users[_].accounts[_]
  not accounts.access in allowed_access
  msg := sprintf("`%v` uses an unexpected access: got `%v`, expected one of: %v", [input.filename, accounts.access, concat(", ", allowed_access) ])
}

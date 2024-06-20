package main

testEmptyFile if {
  deny["`example.json` is an empty file"] with input as { "filename": "example.json" }
}

testNoUsers if {
  deny["`example.json` is missing the `users` key"] with input as { "filename": "example.json" }
}

testNoUsername if {
  deny["`example.json` is missing the `username` key"] with input as { "filename": "example.json", "users": [{}] }
}

testNoGithubUsername if {
  deny["`example.json` is missing the `github-username` key"] with input as { "filename": "example.json", "users": [{}] }
}

testNoAccounts if {
  deny["`example.json` is missing the `accounts` key"] with input as { "filename": "example.json", "users": [{}] }
}

testEmptyValues if {
  deny["`example.json` is missing the `username` key"] with input as { "filename": "example.json", "users": [{"username": ""}] }
  deny["`example.json` is missing the `github-username` key"] with input as { "filename": "example.json", "users": [{"github-username": ""}] }
  deny["`example.json` is missing the `accounts` key"] with input as { "filename": "example.json", "users": [{"accounts": ""}] }
}

testUnexpectedAccess if {
  deny["`example.json` uses an unexpected access: got `incorrect-access`, expected one of: read-only, developer, security-audit, sandbox, migration, instance-management"] with input as { "filename": "example.json", "users": [{"accounts": [{"access": "incorrect-access"}]}] }
}
package main

test_empty_file {
  deny["`example.json` is an empty file"] with input as { "filename": "example.json" }
}

test_no_users {
  deny["`example.json` is missing the `users` key"] with input as { "filename": "example.json" }
}

test_no_username {
  deny["`example.json` is missing the `username` key"] with input as { "filename": "example.json" , "users" :[{}]}
}

test_no_github_username {
  deny["`example.json` is missing the `github-username` key"] with input as { "filename": "example.json" , "users" :[{}]}
}

test_no_accounts {
  deny["`example.json` is missing the `accounts` key"] with input as { "filename": "example.json" , "users" :[{}]}
}

test_empty_values {
  deny["`example.json` is missing the `username` key"] with input as { "filename": "example.json", "users" :[{"username": ""}] }
  deny["`example.json` is missing the `github-username` key"] with input as { "filename": "example.json", "users" :[{"github-username": ""}] }
  deny["`example.json` is missing the `accounts` key"] with input as { "filename": "example.json", "users" :[{"accounts": ""}] }
}

test_unexpected_access {
  deny["`example.json` uses an unexpected access: got `incorrect-access`, expected one of: read-only, developer, security-audit, sandbox, migration"] with input as { "filename": "example.json", "users" :[{"accounts": [{"access": "incorrect-access"}]}] }
}

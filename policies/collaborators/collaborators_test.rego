package policies.collaborators


import rego.v1

test_empty_file if {
  deny["`example.json` is an empty file"] with input as { "filename": "example.json" }
}

test_no_users if {
  deny["`example.json` is missing the `users` key"] with input as { "filename": "example.json" }
}

test_no_username if {
  deny["`example.json` is missing the `username` key"] with input as { "filename": "example.json", "users": [{}] }
}

test_no_github_username if {
  deny["`example.json` is missing the `github-username` key"] with input as { "filename": "example.json", "users": [{}] }
}

test_no_accounts if {
  deny["`example.json` is missing the `accounts` key"] with input as { "filename": "example.json", "users": [{}] }
}

test_empty_values if {
  deny["`example.json` is missing the `username` key"] with input as { "filename": "example.json", "users": [{"username": ""}] }
  deny["`example.json` is missing the `github-username` key"] with input as { "filename": "example.json", "users": [{"github-username": ""}] }
  deny["`example.json` is missing the `accounts` key"] with input as { "filename": "example.json", "users": [{"accounts": ""}] }
}

test_unexpected_access if {
  deny["`example.json` uses an unexpected access: got `incorrect-access`, expected one of: read-only, developer, security-audit, sandbox, migration, instance-management, fleet-manager, platform-engineer-admin, ssm-session-access"] with input as { "filename": "example.json", "users": [{"accounts": [{"access": "incorrect-access"}]}] }
}

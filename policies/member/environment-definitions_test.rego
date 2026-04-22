package policies.member

import rego.v1

test_invalid_file_name_character if {
  deny["`environments/exampleA.json` filename does not meet requirements"] with input as { "filename": "environments/exampleA.json" }
}

test_invalid_file_name_length if {
  deny["`environments/this-is-more-than-thirty-six-characters-long.json` filename does not meet requirements"] with input as { "filename": "environments/this-is-more-than-thirty-six-characters-long.json" }
}

test_valid_file_name_length_thirty_six if {
  # 36-character app name (at limit)
  not deny[_] with input as { "filename": "environments/app-name-exactly-thirty-six-characters-long-ok.json" }
}

test_valid_file_name_exception_thirty_seven if {
  # 37-character exception app name
  not deny[_] with input as { "filename": "environments/analytical-platform-next-poc-producer.json" }
}

test_invalid_file_name_length_thirty_seven_non_exception if {
  # 37-character app name (over limit, not an exception - should fail)
  deny["`environments/app-name-exactly-thirty-seven-characters-long-fail.json` filename does not meet requirements"] with input as { "filename": "environments/app-name-exactly-thirty-seven-characters-long-fail.json" }
}

test_unexpected_environment if {
  deny["`example.json` uses an unexpected environment: got `sandbox`, expected one of: development, test, preproduction, production, nonlive, live"] with input as { "filename": "example.json", "environments": [{ "name": "sandbox" }] }
}

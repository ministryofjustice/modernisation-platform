package main

test_invalid_file_name_character{
  deny["`exampleA.json` filename does not meet requirements"] with input as { "filename": "exampleA.json" }
}

test_invalid_file_name_length{
  deny["`example-this-is-too-long-for-an-application-name.json` filename does not meet requirements"] with input as { "filename": "example-this-is-too-long-for-an-application-name.json" }
}

test_unexpected_environment {
  deny["`example.json` uses an unexpected environment: got `sandbox`, expected one of: development, test, preproduction, production"] with input as { "filename": "example.json", "environments": [{ "name": "sandbox" }] }
}

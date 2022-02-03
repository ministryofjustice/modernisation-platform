package main

sample_input := {
  "filename": "house-sandbox.json",
  "cidr": {
    "subnet_sets": {
      "general": {
      	"cidr": "2.2.2.2"
      }
    }
  }
}

test_mismatched_subnet_sets {
	deny["Subnet sets mismatch: `2.2.2.2` should equal `10.231.8.0/21` for `house-sandbox (general)`"] with input as sample_input
}

test_no_cidr {
  deny["`example.json` is missing the `cidr` key"] with input as { "filename": "example.json" }
}

test_cidr_present {
  not deny["`example.json` is missing the `cidr` key"] with input as { "filename": "example.json", "cidr": {}  }
}

test_missing_cidr_keys {
  deny["`example.json` is missing the `subnet_sets` key"] with input as { "filename": "example.json", "cidr": {} }
}

test_no_options {
  deny["`example.json` is missing the `options` key"] with input as { "filename": "example.json" }
}

test_missing_options_keys {
  deny["`example.json` is missing the `additional_endpoints` key"] with input as { "filename": "example.json", "options": {} }
  deny["`example.json` is missing the `dns_zone_extend` key"] with input as { "filename": "example.json", "options": {} }
}

test_no_nacl {
  deny["`example.json` is missing the `nacl` key"] with input as { "filename": "example.json" }
}

test_cidr_types {
  deny["`example.json` invalid subnet_sets type - must be a object"] with input as { "filename": "example.json", "cidr": {"subnet_sets": ""} }
}

test_option_types {
  deny["`example.json` invalid bastion_linux type - must be boolean"] with input as { "filename": "example.json", "options": {"bastion_linux": "true"} }
  deny["`example.json` invalid additional_endpoints type - must be an array"] with input as { "filename": "example.json", "options": {"additional_endpoints": ""} }
  deny["`example.json` invalid dns_zone_extend type - must be an array"] with input as { "filename": "example.json", "options": {"dns_zone_extend": ""} }
}

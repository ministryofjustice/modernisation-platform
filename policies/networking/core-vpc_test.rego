package main

sample_input := {
  "filename": "garden-development.json",
  "cidr": {
    "transit_gateway": "0.0.0.0",
    "protected": "1.1.1.1",
    "subnet_sets": {
      "general": {
      	"cidr": "2.2.2.2"
      }
    }
  }
}

test_mismatched_transit_gateway_cidr {
	deny["Transit Gateway CIDR mismatch: `0.0.0.0` should equal `10.233.0.0/26` for `garden-development`"] with input as sample_input
}

test_mismatched_protected_cidr {
	deny["Protected CIDR mismatch: `1.1.1.1` should equal `10.238.0.0/23` for `garden-development`"] with input as sample_input
}

test_mismatched_subnet_sets {
	deny["Subnet sets mismatch: `2.2.2.2` should equal `10.234.0.0/21` for `garden-development (general)`"] with input as sample_input
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
  # deny["`example.json` is missing the `bastion_linux` key"] with input as { "filename": "example.json", "options": {} }
  deny["`example.json` is missing the `additional_endpoints` key"] with input as { "filename": "example.json", "options": {} }
  deny["`example.json` is missing the `dns_zone_extend` key"] with input as { "filename": "example.json", "options": {} }
}

test_no_nacl {
  deny["`example.json` is missing the `nacl` key"] with input as { "filename": "example.json" }
}

test_cidr_types {
  deny["`example.json` invalid transit_gateway type - must be string"] with input as { "filename": "example.json", "cidr": {"transit_gateway": true} }
  deny["`example.json` invalid protected type - must be string"] with input as { "filename": "example.json", "cidr": {"protected": true} }
  deny["`example.json` invalid subnet_sets type - must be a object"] with input as { "filename": "example.json", "cidr": {"subnet_sets": ""} }
}

test_option_types {
  deny["`example.json` invalid bastion_linux type - must be boolean"] with input as { "filename": "example.json", "options": {"bastion_linux": "true"} }
  deny["`example.json` invalid additional_endpoints type - must be an array"] with input as { "filename": "example.json", "options": {"additional_endpoints": ""} }
  deny["`example.json` invalid dns_zone_extend type - must be an array"] with input as { "filename": "example.json", "options": {"dns_zone_extend": ""} }
}

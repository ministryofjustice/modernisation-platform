package main

sample_input := {
  "filename": "hmpps-production.json",
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
	deny["Transit Gateway CIDR mismatch: `0.0.0.0` should equal `10.233.0.0/26` for `hmpps-production`"] with input as sample_input
}

test_mismatched_protected_cidr {
	deny["Protected CIDR mismatch: `1.1.1.1` should equal `10.232.0.0/23` for `hmpps-production`"] with input as sample_input
}

test_mismatched_subnet_sets {
	deny["Subnet sets mismatch: `2.2.2.2` should equal `10.233.8.0/21` for `hmpps-production (general)`"] with input as sample_input
}

package main

expected = {
  "transit_gateway": {
    "hmpps-production": "10.233.0.0/26",
    "laa-production": "10.233.0.64/26"
  },
  "protected": {
    "hmpps-production": "10.232.0.0/23",
    "laa-production": "10.232.2.0/23"
  },
  "subnet_sets": {
    "hmpps-production": {
      "general": {
        "cidr": "10.233.8.0/21",
        "accounts": [
          "nomis",
          "oasys",
          "core-sandbox"
        ]
      },
      "delius": {
        "cidr": "10.233.16.0/21",
        "accounts": [
          "delius"
        ]
      }
    },
    "laa-production": {
      "general": {
        "cidr": "10.233.32.0/21",
        "accounts": [
          "get_paid"
        ]
      }
    }
  }
}

nice_name := replace(replace(input.filename, ".json", ""), "environments-networks/", "")

deny[msg] {
  input_cidr = input.cidr.transit_gateway
  expected_cidr = expected["transit_gateway"][nice_name]

  expected_cidr != input_cidr

  msg := sprintf("Transit Gateway CIDR mismatch: `%v` should equal `%v` for `%v`", [input_cidr, expected_cidr, nice_name])
}

deny[msg] {
  input_cidr = input.cidr.protected
  expected_cidr = expected["protected"][nice_name]

  expected_cidr != input_cidr

  msg := sprintf("Protected CIDR mismatch: `%v` should equal `%v` for `%v`", [input_cidr, expected_cidr, nice_name])
}

deny[msg] {
  expected["subnet_sets"][nice_name][key].cidr != input.cidr.subnet_sets[key].cidr

  msg := sprintf("Subnet sets mismatch: `%v` should equal `%v` for `%v (%v)`", [input.cidr.subnet_sets[key].cidr, expected["subnet_sets"][nice_name][key].cidr, nice_name, key])
}

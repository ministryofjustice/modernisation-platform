package main

expected = {
  "transit_gateway": {
    "garden-development": "10.233.0.0/26",
    "house-development": "10.233.0.64/26",
    "garden-production": "10.233.0.128/26",
    "house-production": "10.233.0.192/26"
  },
  "protected": {
    "garden-development": "10.232.0.0/23",
    "house-development": "10.232.2.0/23",
    "garden-production": "10.232.4.0/23",
    "house-production": "10.232.6.0/23"
  },
  "subnet_sets": {
    "garden-development": {
      "general": {
        "cidr": "10.234.0.0/21",
        "accounts": [
          "sprinkler-development",
          "bench-development"
        ]
      },
      "patio": {
        "cidr": "10.234.8.0/21",
        "accounts": [
          "heater-development"
        ]
      }
    },
    "house-development": {
      "general": {
        "cidr": "10.234.16.0/21",
        "accounts": [
          "cooker-development"
        ]
      }
    },
    "garden-production": {
      "general": {
        "cidr": "10.237.0.0/21",
        "accounts": [
          "sprinkler-production",
          "bench-production"
        ]
      },
      "patio": {
        "cidr": "10.237.8.0/21",
        "accounts": [
          "heater-production"
        ]
      }
    },
    "house-production": {
      "general": {
        "cidr": "10.237.16.0/21",
        "accounts": [
          "cooker-production"
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

# General rules
# Missing keys
deny[msg] {
  not has_field(input, "cidr")
  msg := sprintf("`%v` is missing the `cidr` key", [input.filename])
}

deny[msg] {
  not has_field(input.cidr, "transit_gateway")
  msg := sprintf("`%v` is missing the `transit_gateway` key", [input.filename])
}

deny[msg] {
  not has_field(input.cidr, "protected")
  msg := sprintf("`%v` is missing the `protected` key", [input.filename])
}

deny[msg] {
  not has_field(input.cidr, "subnet_sets")
  msg := sprintf("`%v` is missing the `subnet_sets` key", [input.filename])
}

deny[msg] {
  not has_field(input, "options")
  msg := sprintf("`%v` is missing the `options` key", [input.filename])
}

deny[msg] {
  not has_field(input.options, "bastion_linux")
  msg := sprintf("`%v` is missing the `bastion_linux` key", [input.filename])
}

deny[msg] {
  not has_field(input.options, "additional_endpoints")
  msg := sprintf("`%v` is missing the `additional_endpoints` key", [input.filename])
}

deny[msg] {
  not has_field(input.options, "dns_zone_extend")
  msg := sprintf("`%v` is missing the `dns_zone_extend` key", [input.filename])
}

deny[msg] {
  not has_field(input, "nacl")
  msg := sprintf("`%v` is missing the `nacl` key", [input.filename])
}

# Invalid type
deny[msg] {
  not is_string(input.cidr.transit_gateway)
  msg := sprintf("`%v` invalid transit_gateway type - must be string", [input.filename])
}

deny[msg] {
  not is_string(input.cidr.protected)
  msg := sprintf("`%v` invalid protected type - must be string", [input.filename])
}

deny[msg] {
  not is_object(input.cidr.subnet_sets)
  msg := sprintf("`%v` invalid subnet_sets type - must be a object", [input.filename])
}

deny[msg] {
  not is_boolean(input.options.bastion_linux)
  msg := sprintf("`%v` invalid bastion type - must be boolean", [input.filename])
}

deny[msg] {
  not is_array(input.options.additional_endpoints)
  msg := sprintf("`%v` invalid additional_endpoints type - must be an array", [input.filename])
}

deny[msg] {
  not is_array(input.options.dns_zone_extend)
  msg := sprintf("`%v` invalid dns_zone_extend type - must be an array", [input.filename])
}

deny[msg] {
  not is_array(input.nacl)
  msg := sprintf("`%v` invalid nacl type - must be an array", [input.filename])
}

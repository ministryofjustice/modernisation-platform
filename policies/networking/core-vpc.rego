package main

nice_name := replace(replace(input.filename, ".json", ""), "environments-networks/", "")

# Match cidrs against expected.rego
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
  not has_field(input.cidr, "subnet_sets")
  msg := sprintf("`%v` is missing the `subnet_sets` key", [input.filename])
}

deny[msg] {
  not has_field(input, "options")
  msg := sprintf("`%v` is missing the `options` key", [input.filename])
}

# deny[msg] {
#   not has_field(input.options, "bastion_linux")
#   msg := sprintf("`%v` is missing the `bastion_linux` key", [input.filename])
# }

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
  msg := sprintf("`%v` invalid bastion_linux type - must be boolean", [input.filename])
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

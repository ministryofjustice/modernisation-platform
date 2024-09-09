package policies.networking

import rego.v1

nice_name := replace(replace(input.filename, ".json", ""), "environments-networks/", "")

deny contains msg if {
  some key
  expected["subnet_sets"][nice_name][key].cidr != input.cidr.subnet_sets[key].cidr

  msg := sprintf("Subnet sets mismatch: `%v` should equal `%v` for `%v (%v)`", [input.cidr.subnet_sets[key].cidr, expected["subnet_sets"][nice_name][key].cidr, nice_name, key])
}

# General rules
# Missing keys
deny contains msg if {
  not has_field(input, "cidr")
  msg := sprintf("`%v` is missing the `cidr` key", [input.filename])
}

deny contains msg if {
  not has_field(input.cidr, "subnet_sets")
  msg := sprintf("`%v` is missing the `subnet_sets` key", [input.filename])
}

deny contains msg if {
  not has_field(input, "options")
  msg := sprintf("`%v` is missing the `options` key", [input.filename])
}

deny contains msg if {
  not has_field(input.options, "additional_endpoints")
  msg := sprintf("`%v` is missing the `additional_endpoints` key", [input.filename])
}

deny contains msg if {
  not has_field(input.options, "dns_zone_extend")
  msg := sprintf("`%v` is missing the `dns_zone_extend` key", [input.filename])
}

# Invalid type
deny contains msg if {
  not is_object(input.cidr.subnet_sets)
  msg := sprintf("`%v` invalid subnet_sets type - must be a object", [input.filename])
}

deny contains msg if {
  not is_boolean(input.options.bastion_linux)
  msg := sprintf("`%v` invalid bastion_linux type - must be boolean", [input.filename])
}

deny contains msg if {
  not is_array(input.options.additional_endpoints)
  msg := sprintf("`%v` invalid additional_endpoints type - must be an array", [input.filename])
}

deny contains msg if {
  not is_array(input.options.dns_zone_extend)
  msg := sprintf("`%v` invalid dns_zone_extend type - must be an array", [input.filename])
}

deny contains msg if {
  not is_array(input.nacl)
  msg := sprintf("`%v` invalid nacl type - must be an array", [input.filename])
}

# Check that application name is appended with environment name
deny contains msg if {
  some account in input.cidr.subnet_sets.general.accounts
  not regex.match(`\S+(-development|-test|-preproduction|-production)`, account)
  msg := sprintf("%v does not end include the environment name e.g. *-development|*-test|*-preproduction|*-production", [account])
}
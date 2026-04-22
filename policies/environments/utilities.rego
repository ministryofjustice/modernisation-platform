package policies.environments

import rego.v1

has_field(obj, field) if {
	field in object.keys(obj)
	obj[field] != ""
}

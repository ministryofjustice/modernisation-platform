package policies.collaborators

import rego.v1

has_field(obj, field) if {
	obj[field]
	obj[field] != ""
}
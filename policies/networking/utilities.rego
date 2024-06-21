package main

import rego.v1

has_field(object, field) if {
	object[field]
	object[field] != ""
}
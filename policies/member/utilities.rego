package main

import rego.v1

has_field(object, custom_field) if {
	object[custom_field]
	object[custom_field] != ""
}
package main

import rego.v1

has_field(object, attr_name) if {
	object[attr_name]
	object[attr_name] != ""
}
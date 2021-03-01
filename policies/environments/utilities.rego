package main

has_field(object, field) {
  object[field]
  object[field] != ""
}

array_contains(array, element) {
  array[_] = element
}

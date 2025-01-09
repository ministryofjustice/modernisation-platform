variable "networking" {

  type = list(any)

}

variable "circleci_known_thumbprints" {
  type        = list(string)
  description = "The known intermediary thumbprints for the circle ci provider"
  default = [
    "06B25927C42A721631C1EFD9431E648FA62E1E39"
  ]
}

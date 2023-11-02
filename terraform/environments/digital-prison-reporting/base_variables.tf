variable "networking" {

  type = list(any)

}

variable "circleci_known_thumbprints" {
  type        = list(string)
  description = "The known intermediary thumbprints for the circle ci provider"
  default = [
    "9E99A48A9960B14926BB7F3B02E22DA2B0AB7280"
  ]
}

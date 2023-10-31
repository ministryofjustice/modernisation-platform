variable "networking" {

  type = list(any)

}

variable "github_known_thumbprints" {
  type        = list(string)
  description = "The known intermediary thumbprints for the GitHub OIDC provider"
  default     = [
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

variable "circleci_known_thumbprints" {
  type        = list(string)
  description = "The known intermediary thumbprints for the circle ci provider"
  default     = [
    "9E99A48A9960B14926BB7F3B02E22DA2B0AB7280"
  ]
}

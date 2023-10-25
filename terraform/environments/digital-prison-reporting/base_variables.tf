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
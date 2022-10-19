variable "tags_common" {
  description = "MOJ required tags"
  type        = map(string)
}

variable "app_name" {
  description = "base name for ecr repo"
  type        = string
}

variable "push_principals" {
  description = "AWS principals which require access to push to the repository"
  type        = list(string)
  default     = []
}

variable "pull_principals" {
  description = "AWS principals which require access to pull from the repository"
  type        = list(string)
  default     = []
}

variable "enable_retrieval_policy_for_lambdas" {
  description = "If set then it will add ECR Image Retrieval Policy for the given Lambda functions"
  type        = list(string)
  default     = []
}

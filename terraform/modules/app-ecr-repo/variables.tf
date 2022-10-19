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

variable "enable_lambda_retrieval_policy" {
  description = "If set to true, it will add Lambda ECR Image Retrieval Policy"
  type   = bool
  default = false
}

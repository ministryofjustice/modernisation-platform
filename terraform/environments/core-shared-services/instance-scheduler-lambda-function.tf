variable "MyOutput" {
  description = "The ECR repository to query"
  type        = string
}

output "MyOutput" {
  description = ""
  value       = module.instance_scheduler_ecr_repo.ecr_repository_name
}
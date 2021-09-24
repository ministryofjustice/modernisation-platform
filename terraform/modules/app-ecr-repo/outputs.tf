output "ecr_repository_name" {
  description = "ECR Repo Name"
  value       = aws_ecr_repository.ecr_repo.name
}
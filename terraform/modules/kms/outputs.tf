output "key_arns" {
  value = {
    ebs     = aws_kms_key.ebs.arn
    general = aws_kms_key.general.arn
    rds     = aws_kms_key.rds.arn
  }
  description = "Map of created KMS Key Arns where the map keys are 'ebs', 'general' and 'rds'"
}

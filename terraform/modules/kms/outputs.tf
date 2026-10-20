output "key_arns" {
  value = {
    ebs     = aws_kms_key.ebs.arn
    general = aws_kms_key.general.arn
    rds     = aws_kms_key.rds.arn
  }
  description = "Map of created KMS key arns where the map keys are 'ebs', 'general' and 'rds'"
}

output "key_ids" {
  value = {
    ebs     = aws_kms_key.ebs.key_id
    general = aws_kms_key.general.key_id
    rds     = aws_kms_key.rds.key_id
  }
  description = "Map of created KMS key ids where the map keys are 'ebs', 'general' and 'rds'"
}

output "bastion_private_ip" {
  description = "Private IP of bastion"
  value       = aws_instance.bastion_linux.private_ip
}

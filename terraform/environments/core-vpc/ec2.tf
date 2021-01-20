# resource "aws_instance" "bastion" {
#   ami                         = "ami-0e80a462ede03e653"
#   instance_type               = "t3.micro"
#   key_name                    = aws_key_pair.deployer.key_name
#   subnet_id                   = "" # fill this out with a public subnet
#   associate_public_ip_address = true

#   tags = {
#     Name = "playground-bastion"
#   }
# }

# resource "aws_instance" "secure-service" {
#   ami           = "ami-0e80a462ede03e653"
#   instance_type = "t3.micro"
#   key_name      = aws_key_pair.deployer.key_name
#   subnet_id     = "" # fill this out with a private subnet

#   tags = {
#     Name = "playground-secure-service"
#   }
# }

# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = "{#redacted}"
# }

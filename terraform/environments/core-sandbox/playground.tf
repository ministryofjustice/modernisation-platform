data "aws_caller_identity" "current" {}

data "aws_ami_ids" "example" {
  owners     = ["self"]
   filter {
     name   = "name"
     values = ["oracle-linux-5.11*"]
   }
}

output "amis" {
  value = data.aws_ami_ids.example.ids
}
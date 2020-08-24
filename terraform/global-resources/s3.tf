resource "aws_s3_bucket" "modernisation-platform-terraform-state" {
  bucket = "modernisation-platform-terraform-state"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    local.global_resources
  }
}

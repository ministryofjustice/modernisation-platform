data "aws_s3_bucket" "mod_platform_artefact" {
  provider = aws.modernisation-platform
  bucket   = "mod-platform-image-artefact-bucket20230203091453221500000001"
}
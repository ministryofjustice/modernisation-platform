data "aws_s3_bucket" "mod_platform_artefact" {
  provider = aws.core-shared-services
  bucket   = "mod-platform-image-artefact-bucket20230203091453221500000001"
}
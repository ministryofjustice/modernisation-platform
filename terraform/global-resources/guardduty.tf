## This file is automatically generated based on what regions are enabled in an AWS account
## and what regions GuardDuty is available in.

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "ap-northeast-1" {
  provider = aws.ap-northeast-1
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "ap-northeast-2" {
  provider = aws.ap-northeast-2
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "ap-south-1" {
  provider = aws.ap-south-1
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "ap-southeast-1" {
  provider = aws.ap-southeast-1
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "ap-southeast-2" {
  provider = aws.ap-southeast-2
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "ca-central-1" {
  provider = aws.ca-central-1
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "eu-central-1" {
  provider = aws.eu-central-1
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "eu-north-1" {
  provider = aws.eu-north-1
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "eu-west-1" {
  provider = aws.eu-west-1
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "eu-west-2" {
  provider = aws.eu-west-2
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "eu-west-3" {
  provider = aws.eu-west-3
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "sa-east-1" {
  provider = aws.sa-east-1
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "us-east-1" {
  provider = aws.us-east-1
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "us-east-2" {
  provider = aws.us-east-2
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "us-west-1" {
  provider = aws.us-west-1
  enable   = true
}

# Enable GuardDuty in each available region
resource "aws_guardduty_detector" "us-west-2" {
  provider = aws.us-west-2
  enable   = true
}


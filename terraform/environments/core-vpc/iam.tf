data "aws_iam_role" "vpc-flow-log" {
  name = "AWSVPCFlowLog"
}
resource "aws_iam_policy" "policy" {
  name  = "s3_lock_access_policy"
  path        = "/"
  description = "S3 and dynamo policy"

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mybucket"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::modernisation-platform-terraform-state"
    }
  ]
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ],
        "Resource" : ["arn:aws:dynamodb:eu-west-2:946070829339:table/modernisation-platform-terraform-state-lock"],
        "Condition" : {
          "ForAllValues:StringEquals" : {
            "dynamodb:LeadingKeys" : [
              "myorg-terraform-states/myapp/production/tfstate", // during a state lock the full state file is stored with this key
              "myorg-terraform-states/myapp/production/tfstate-md5" // after the lock is released a hash of the statefile's contents are stored with this key
            ]
          }
        }
      }
  ]
}
  ) 
}
# resource "aws_ram_resource_share" "shared-services" {
#   provider = aws.core-network-services

#   name                      = "shared-services"
#   allow_external_principals = true

#   tags = merge(
#     local.tags,
#     {
#       Name = "shared-services"
#     },
#   )
# }

# data "aws_ec2_transit_gateway" "transit_gateway_id" {
#   provider = aws.core-network-services

#   filter {
#     name   = "options.amazon-side-asn"
#     values = ["64589"]
#   }
# }

# # Share the transit gateway...
# resource "aws_ram_resource_association" "ram-association" {
#   provider = aws.core-network-services

#   resource_arn       = data.aws_ec2_transit_gateway.transit_gateway_id.arn
#   resource_share_arn = aws_ram_resource_share.shared-services.id
# }

# # ...with the second account.
# resource "aws_ram_principal_association" "transit_gateway_association" {
#   provider = aws.core-network-services

#   principal          = data.aws_caller_identity.current.account_id
#   resource_share_arn = aws_ram_resource_share.shared-services.arn
# }

# resource "aws_iam_role" "iam_for_lambda" {
#   name = "iam_for_lambda"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_policy" "lambda_logging" {
#   name        = "lambda_logging"
#   path        = "/"
#   description = "IAM policy for logging from a lambda"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource": "arn:aws:logs:*:*:*",
#       "Effect": "Allow"
#     },
#     {
#       "Action": ["ram:*"],
#       "Effect": "Allow",
#       "Resource": ["*"]
#     }
#   ]
# }
# EOF
# }

# resource "aws_cloudwatch_log_group" "example" {
#   name              = "/aws/lambda/lambda_function_name"
#   retention_in_days = 14
# }

# resource "aws_iam_role_policy_attachment" "lambda_logs" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = aws_iam_policy.lambda_logging.arn
# }

# resource "aws_lambda_function" "test_lambda" {
#   filename      = "accepter.zip"
#   function_name = "lambda_function_name"
#   role          = aws_iam_role.iam_for_lambda.arn
#   handler       = "accepter.handler"

#   depends_on = [
#     aws_iam_role_policy_attachment.lambda_logs,
#     aws_cloudwatch_log_group.example,
#   ]

#   # The filebase64sha256() function is available in Terraform 0.11.12 and later
#   # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
#   # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
#   source_code_hash = filebase64sha256("accepter.js")
#   runtime = "nodejs12.x"
# }

# data "archive_file" "init" {
#   type        = "zip"
#   source_file = "accepter.js"
#   output_path = "accepter.zip"
# }

# data "aws_lambda_invocation" "example" {
#   depends_on = [aws_lambda_function.test_lambda]
#   function_name = aws_lambda_function.test_lambda.function_name
#   input = <<JSON
# {}
# JSON
# }

# output "result_entry" {
#   value = jsondecode(data.aws_lambda_invocation.example.result)
# }

# # resource "aws_ram_resource_share_accepter" "receiver_accept" {
# #   # provider = aws.core-network-services

# #   depends_on = [
# #     time_sleep.wait_60_seconds
# #   ]
# #   share_arn = aws_ram_principal_association.transit_gateway_association.resource_share_arn
# # }

# resource "time_sleep" "wait_30_seconds" {
#   depends_on = [
#     data.aws_lambda_invocation.example
#   ]

#   create_duration = "60s"
# }

# # Create the VPC attachment in the second account...
# resource "aws_ec2_transit_gateway_vpc_attachment" "live" {
#   depends_on = [
#     aws_ram_principal_association.transit_gateway_association,
#     aws_ram_resource_association.ram-association,
#     time_sleep.wait_30_seconds,
#     data.aws_lambda_invocation.example
#   ]

#   subnet_ids         = module.vpc["live"].tgw_subnet_ids
#   transit_gateway_id = data.aws_ec2_transit_gateway.transit_gateway_id.id
#   vpc_id             = module.vpc["live"].vpc_id

#   transit_gateway_default_route_table_association = false
#   transit_gateway_default_route_table_propagation = false

#   tags = {
#     Name = "terraform-example"
#     Side = "Creator"
#   }
# }
# #
# # # ...and accept it in the first account.
# resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "live" {
#   provider = aws.core-network-services

#   depends_on = [
#     time_sleep.wait_30_seconds,
#     aws_ec2_transit_gateway_vpc_attachment.live,
#     data.aws_lambda_invocation.example
#   ]

#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.live.id
#   transit_gateway_default_route_table_association = false
#   transit_gateway_default_route_table_propagation = false

#   tags = {
#     Name = "terraform-example"
#     Side = "Accepter"
#   }
# }

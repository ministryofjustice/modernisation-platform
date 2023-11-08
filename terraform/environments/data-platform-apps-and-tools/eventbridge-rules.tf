resource "aws_cloudwatch_event_rule" "auth0_cloudwatch" {
  name           = "auth0-to-cloudwatch-logs"
  event_bus_name = data.aws_cloudwatch_event_bus.auth0.name

  event_pattern = jsonencode({
    source = [{
      prefix = "aws.partner/auth0.com"
    }]
  })
}
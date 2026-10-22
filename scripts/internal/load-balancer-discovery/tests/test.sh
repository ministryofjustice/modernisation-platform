#!/usr/bin/env bash
set -euo pipefail

directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin"
cp "$directory/tests/aws.sh" "$work/bin/aws"
chmod +x "$work/bin/aws"
export PATH="$work/bin:$PATH"
export AWS_CALLS="$work/calls"

bash "$directory/discover.sh" example-development "eu-west-2, eu-west-1,eu-west-2" > "$work/result.json"
jq -e '
  .account_name == "example-development"
  and .account_id == "123456789012"
  and .regions == ["eu-west-1","eu-west-2"]
  and (.load_balancers | length) == 3
  and (.web_acls | length) == 4
  and ([.load_balancers[] | select(.access_logging_enabled)] | length) == 2
  and ([.web_acls[] | select(.logging_enabled)] | length) == 3
  and (.load_balancers[] | select(.name == "app") |
    .s3_bucket == "example-logs" and .s3_prefix == "logs/application"
    and .access_log_uri == "s3://example-logs/logs/application/AWSLogs/123456789012/elasticloadbalancing/eu-west-2/"
    and .waf_web_acl_arns == ["arn:aws:wafv2:eu-west-2:123456789012:regional/webacl/regional/id"])
  and (.load_balancers[] | select(.name == "net") |
    .access_logging_enabled == false and .access_log_uri == null and .waf_web_acl_arns == [])
  and (.load_balancers[] | select(.name == "tls") |
    .access_log_uri == "s3://example-logs/AWSLogs/123456789012/elasticloadbalancing/eu-west-2/")
  and (.web_acls[] | select(.name == "regional") |
    .logging_destinations == ["arn:aws:s3:::aws-waf-logs-example"]
    and .alb_arns == ["arn:aws:elasticloadbalancing:eu-west-2:123456789012:loadbalancer/app"]
    and .logging_configurations[0].LoggingFilter.DefaultBehavior == "KEEP"
    and .logging_configurations[0].LogScope == "CUSTOMER"
    and .logging_configurations[0].RedactedFields == [{SingleHeader:{Name:"authorization"}}])
  and (.web_acls[] | select(.name == "disabled") |
    .logging_enabled == false and .logging_destinations == []
    and .logging_configurations == [] and .alb_arns == [])
  and (.web_acls[] | select(.name == "cloudfront") |
    .scope == "CLOUDFRONT" and .region == "us-east-1"
    and .logging_destinations == ["arn:aws:logs:us-east-1:123456789012:log-group:aws-waf-logs-example"])
  and (.web_acls[] | select(.name == "firehose") |
    .logging_destinations == ["arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-example"])
' "$work/result.json" > /dev/null
[[ "$(grep -c 'wafv2 list-web-acls us-east-1 CLOUDFRONT' "$AWS_CALLS")" -eq 2 ]]
grep -q 'second-acl-page' "$AWS_CALLS"
grep -q 'second-logging-page' "$AWS_CALLS"
[[ "$(grep -c 'elbv2 describe-load-balancers' "$AWS_CALLS")" -eq 2 ]]
echo "PASS: ALB/NLB logging, paginated WAF destinations, filters, redaction, associations and region deduplication"

FAKE_CASE=empty bash "$directory/discover.sh" example-development eu-west-2 > "$work/empty.json"
jq -e '.load_balancers == [] and .web_acls == [] and .account_name == "example-development"' "$work/empty.json" > /dev/null
echo "PASS: empty accounts remain explicitly represented"

FAKE_CASE=managed-logging bash "$directory/discover.sh" example-development eu-west-2 > "$work/managed.json"
jq -e '
  .web_acls[] | select(.name == "disabled") |
  .logging_enabled == true
  and .logging_destinations == ["arn:aws:s3:::managed-waf-logs"]
  and (.logging_configurations | map(.LogScope) | sort) == ["CLOUDWATCH_TELEMETRY_RULE_MANAGED","SECURITY_LAKE"]
' "$work/managed.json" > /dev/null
echo "PASS: managed logging is not incorrectly reported as disabled"

for scenario in get-caller-identity-failure describe-load-balancers-failure \
  describe-load-balancer-attributes-failure list-web-acls-failure \
  list-logging-configurations-failure list-resources-for-web-acl-failure \
  missing-flag invalid-flag missing-bucket later-acl-page-failure \
  later-logging-page-failure repeated-marker malformed-acls; do
  if FAKE_CASE="$scenario" bash "$directory/discover.sh" example-development eu-west-2 > "$work/error.json" 2> "$work/error.log"; then
    echo "Expected failure for $scenario" >&2
    exit 1
  fi
  [[ ! -s "$work/error.json" ]]
  [[ -s "$work/error.log" ]]
  echo "PASS: $scenario fails explicitly without publishing partial results"
done

for arguments in missing-account empty-regions; do
  if [[ "$arguments" == "missing-account" ]]; then
    args=("")
  else
    args=("example-development" ", ,")
  fi
  if bash "$directory/discover.sh" "${args[@]}" > "$work/error.json" 2> "$work/error.log"; then
    echo "Expected validation failure for $arguments" >&2
    exit 1
  fi
  [[ -s "$work/error.log" ]]
done
echo "PASS: invalid inputs are rejected"

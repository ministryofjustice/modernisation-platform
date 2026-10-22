#!/usr/bin/env bash
set -euo pipefail

service="$1" operation="$2"
shift 2
region="" scope="" arn="" marker="" log_scope=""
while (( $# > 0 )); do
  case "$1" in
    --region) region="$2"; shift 2 ;;
    --scope) scope="$2"; shift 2 ;;
    --next-marker) marker="$2"; shift 2 ;;
    --log-scope) log_scope="$2"; shift 2 ;;
    --load-balancer-arn|--web-acl-arn) arn="$2"; shift 2 ;;
    --resource-type|--output|--limit) shift 2 ;;
    --no-cli-pager) shift ;;
    *) echo "Unexpected AWS argument: $1" >&2; exit 1 ;;
  esac
done
echo "$service $operation $region $scope $arn $marker $log_scope" >> "$AWS_CALLS"
if [[ "${FAKE_CASE:-}" == "$operation-failure" ]]; then
  echo "AccessDenied: $operation" >&2
  exit 1
fi
if [[ ( "${FAKE_CASE:-}" == "later-acl-page-failure" && "$operation" == "list-web-acls" && -n "$marker" ) ||
      ( "${FAKE_CASE:-}" == "later-logging-page-failure" && "$operation" == "list-logging-configurations" && -n "$marker" ) ]]; then
  echo "AccessDenied: later page of $operation" >&2
  exit 1
fi

case "$service $operation" in
  "sts get-caller-identity") echo '{"Account":"123456789012"}' ;;
  "elbv2 describe-load-balancers")
    if [[ "${FAKE_CASE:-}" == "empty" || "$region" != "eu-west-2" ]]; then
      echo '{"LoadBalancers":[]}'
    else
      jq -nc '{
        LoadBalancers: ([
          {name:"app",type:"application"},
          {name:"net",type:"network"},
          {name:"tls",type:"network"},
          {name:"gateway",type:"gateway"}
        ] | map({
          LoadBalancerName:.name, Type:.type, DNSName:(.name + ".example.test"),
          Scheme:"internet-facing",
          LoadBalancerArn:("arn:aws:elasticloadbalancing:eu-west-2:123456789012:loadbalancer/" + .name)
        }))
      }'
    fi
    ;;
  "elbv2 describe-load-balancer-attributes")
    enabled=true
    prefix='logs/application'
    bucket='example-logs'
    case "$arn" in
      */net) enabled=false ;;
      */tls) prefix='' ;;
      */gateway) echo "Gateway LB should be excluded" >&2; exit 1 ;;
    esac
    case "${FAKE_CASE:-}" in
      invalid-flag) enabled=unknown ;;
      missing-bucket) bucket='' ;;
    esac
    jq -nc --arg enabled "$enabled" --arg prefix "$prefix" --arg bucket "$bucket" --arg scenario "${FAKE_CASE:-}" '{
      Attributes: ([
        {Key:"access_logs.s3.enabled",Value:$enabled},
        {Key:"access_logs.s3.bucket",Value:$bucket},
        {Key:"access_logs.s3.prefix",Value:$prefix}
      ] | if $scenario == "missing-flag" then map(select(.Key != "access_logs.s3.enabled")) else . end)
    }'
    ;;
  "wafv2 list-web-acls")
    if [[ "${FAKE_CASE:-}" == "malformed-acls" ]]; then
      echo '{"UnexpectedField":[]}'
      exit 0
    fi
    if [[ "${FAKE_CASE:-}" == "empty" || ( "$scope" == "REGIONAL" && "$region" != "eu-west-2" ) ]]; then
      echo '{"WebACLs":[]}'
    else
      jq -nc --arg scope "$scope" --arg region "$region" --arg marker "$marker" --arg scenario "${FAKE_CASE:-}" '{
        WebACLs: (
          (if $scope == "REGIONAL" then ["regional","disabled"] else ["cloudfront","firehose"] end)
          | if $marker == "" then .[:1] else .[1:] end
          | map({
            Name:., Id:("id-" + .),
            ARN:("arn:aws:wafv2:" + $region + ":123456789012:"
              + (if $scope == "REGIONAL" then "regional" else "global" end) + "/webacl/" + . + "/id")
          })
        ),
        NextMarker: (if $marker == "" or $scenario == "repeated-marker" then "second-acl-page" else null end)
      }'
    fi
    ;;
  "wafv2 list-logging-configurations")
    if [[ "${FAKE_CASE:-}" == "managed-logging" && "$scope" == "REGIONAL" && "$region" == "eu-west-2" && "$log_scope" != "CUSTOMER" ]]; then
      jq -nc --arg log_scope "$log_scope" '{
        LoggingConfigurations:[{
          ResourceArn:"arn:aws:wafv2:eu-west-2:123456789012:regional/webacl/disabled/id",
          LogDestinationConfigs:["arn:aws:s3:::managed-waf-logs"],
          LogScope:$log_scope
        }]
      }'
    elif [[ "${FAKE_CASE:-}" == "empty" || ( "$scope" == "REGIONAL" && "$region" != "eu-west-2" ) || "$log_scope" != "CUSTOMER" ]]; then
      echo '{"LoggingConfigurations":[]}'
    else
      jq -nc --arg scope "$scope" --arg region "$region" --arg marker "$marker" '{
        LoggingConfigurations: (
          (if $scope == "REGIONAL" then ["regional"] else ["cloudfront","firehose"] end)
          | if $marker == "" then .[:1] else .[1:] end
          | map({
            ResourceArn:("arn:aws:wafv2:" + $region + ":123456789012:"
              + (if $scope == "REGIONAL" then "regional" else "global" end) + "/webacl/" + . + "/id"),
            LogDestinationConfigs: [
              if . == "regional" then "arn:aws:s3:::aws-waf-logs-example"
              elif . == "cloudfront" then "arn:aws:logs:us-east-1:123456789012:log-group:aws-waf-logs-example"
              else "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-example" end
            ],
            RedactedFields:[{SingleHeader:{Name:"authorization"}}],
            LoggingFilter:{DefaultBehavior:"KEEP",Filters:[]}
          })
        ),
        NextMarker: (if $marker == "" then "second-logging-page" else null end)
      }'
    fi
    ;;
  "wafv2 list-resources-for-web-acl")
    if [[ "$arn" == *:global/* ]]; then
      echo "CloudFront ACLs cannot have ALB associations" >&2
      exit 1
    fi
    if [[ "$arn" == */webacl/regional/id ]]; then
      echo '{"ResourceArns":["arn:aws:elasticloadbalancing:eu-west-2:123456789012:loadbalancer/app"]}'
    else
      echo '{"ResourceArns":[]}'
    fi
    ;;
  *) echo "Unexpected AWS operation: $service $operation" >&2; exit 1 ;;
esac

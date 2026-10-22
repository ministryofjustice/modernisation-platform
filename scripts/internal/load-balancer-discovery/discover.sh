#!/usr/bin/env bash
set -euo pipefail

account_name="${1:-${ACCOUNT_NAME:-}}"
region_list="${2:-eu-central-1,eu-west-1,eu-west-2,eu-west-3,us-east-1}"
if [[ -z "$account_name" ]]; then
  echo "Usage: bash discover.sh ACCOUNT_NAME [COMMA_SEPARATED_REGIONS]" >&2
  exit 1
fi
regions="$(jq -nc --arg value "$region_list" '$value | split(",") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0)) | unique')"
if [[ "$(jq length <<< "$regions")" -eq 0 ]]; then
  echo "At least one region is required" >&2
  exit 1
fi

aws_json() {
  aws "$@" --output json --no-cli-pager
}

# WAFv2 list operations do not have AWS CLI automatic paginators.
waf_list() {
  local operation="$1" field="$2"
  shift 2
  local marker="" next page items='[]'
  local request_args=("$@" --limit 100)
  while :; do
    page="$(aws_json wafv2 "$operation" "${request_args[@]}")" || return
    items="$(jq -nce --argjson items "$items" --argjson page "$page" --arg field "$field" \
      '$items + ($page[$field] | select(type == "array"))')" || return
    next="$(jq -r '.NextMarker // empty' <<< "$page")" || return
    if [[ -z "$next" ]]; then break; fi
    if [[ "$next" == "$marker" ]]; then
      echo "Repeated WAF pagination marker for $operation" >&2
      return 1
    fi
    marker="$next"
    request_args=("$@" --limit 100 --next-marker "$marker")
  done
  printf '%s\n' "$items"
}

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
: > "$work/load-balancers.jsonl"
: > "$work/web-acls.jsonl"
account_id="$(aws_json sts get-caller-identity --region "$(jq -r '.[0]' <<< "$regions")" | jq -er '.Account')"

discover_web_acls() {
  local scope="$1" region="$2" acls logging='[]' configs log_scope acl arn associations
  acls="$(waf_list list-web-acls WebACLs --scope "$scope" --region "$region")"
  for log_scope in CUSTOMER SECURITY_LAKE CLOUDWATCH_TELEMETRY_RULE_MANAGED; do
    configs="$(waf_list list-logging-configurations LoggingConfigurations \
      --scope "$scope" --region "$region" --log-scope "$log_scope")"
    logging="$(jq -nc --argjson existing "$logging" --argjson configs "$configs" --arg log_scope "$log_scope" \
      '$existing + ($configs | map(. + {LogScope: (.LogScope // $log_scope)}))')"
  done

  while IFS= read -r acl; do
    arn="$(jq -er '.ARN' <<< "$acl")"
    associations='[]'
    if [[ "$scope" == "REGIONAL" ]]; then
      associations="$(aws_json wafv2 list-resources-for-web-acl --web-acl-arn "$arn" --resource-type APPLICATION_LOAD_BALANCER --region "$region" | jq -ce '.ResourceArns | select(type == "array")')"
    fi
    jq -nc \
      --arg account_name "$account_name" --arg account_id "$account_id" \
      --arg region "$region" --arg scope "$scope" \
      --argjson acl "$acl" --argjson logging "$logging" --argjson associations "$associations" '
        ($logging | map(select(.ResourceArn == $acl.ARN))) as $configs
        | {
            account_name: $account_name, account_id: $account_id, region: $region,
            scope: $scope, name: $acl.Name, arn: $acl.ARN, id: $acl.Id,
            logging_enabled: (($configs | length) > 0),
            logging_destinations: ([$configs[].LogDestinationConfigs[]] | unique),
            logging_configurations: $configs,
            alb_arns: $associations
          }
      ' >> "$work/web-acls.jsonl"
  done < <(jq -c '.[]' <<< "$acls")
}

while IFS= read -r region; do
  echo "Discovering ALB/NLB and regional WAF logging in $region" >&2
  load_balancers="$(aws_json elbv2 describe-load-balancers --region "$region")"
  jq -e '.LoadBalancers | type == "array"' <<< "$load_balancers" > /dev/null
  while IFS= read -r lb; do
    arn="$(jq -er '.LoadBalancerArn' <<< "$lb")"
    attributes="$(aws_json elbv2 describe-load-balancer-attributes --load-balancer-arn "$arn" --region "$region")"
    jq -nc \
      --arg account_name "$account_name" --arg account_id "$account_id" --arg region "$region" \
      --argjson lb "$lb" --argjson attributes "$attributes" '
        ($attributes.Attributes | map({key: .Key, value: .Value}) | from_entries) as $attrs
        | $attrs["access_logs.s3.enabled"] as $enabled
        | if $enabled != "true" and $enabled != "false"
          then error("Missing or invalid access_logs.s3.enabled for " + $lb.LoadBalancerArn) else . end
        | ($attrs["access_logs.s3.bucket"] // "") as $bucket
        | ($attrs["access_logs.s3.prefix"] // "") as $prefix
        | if $enabled == "true" and $bucket == ""
          then error("Access logging enabled without a bucket for " + $lb.LoadBalancerArn) else . end
        | {
            account_name: $account_name, account_id: $account_id, region: $region,
            name: $lb.LoadBalancerName, arn: $lb.LoadBalancerArn, type: $lb.Type,
            dns_name: $lb.DNSName, scheme: $lb.Scheme,
            access_logging_enabled: ($enabled == "true"),
            s3_bucket: $bucket, s3_prefix: $prefix,
            access_log_uri: (
              if $enabled == "true" then
                "s3://" + $bucket + "/" + (if $prefix == "" then "" else $prefix + "/" end)
                + "AWSLogs/" + $account_id + "/elasticloadbalancing/" + $region + "/"
              else null end
            )
          }
      ' >> "$work/load-balancers.jsonl"
  done < <(jq -c '.LoadBalancers[] | select(.Type == "application" or .Type == "network")' <<< "$load_balancers")
  discover_web_acls REGIONAL "$region"
done < <(jq -r '.[]' <<< "$regions")

echo "Discovering CloudFront-scoped WAF logging in us-east-1" >&2
discover_web_acls CLOUDFRONT us-east-1

jq -n \
  --arg account_name "$account_name" --arg account_id "$account_id" --argjson regions "$regions" \
  --slurpfile lbs "$work/load-balancers.jsonl" --slurpfile acls "$work/web-acls.jsonl" '
    {
      account_name: $account_name, account_id: $account_id, regions: $regions,
      load_balancers: (
        $lbs | map(. as $lb | . + {
          waf_web_acl_arns: [$acls[] | select(.alb_arns | index($lb.arn)) | .arn]
        }) | sort_by(.region, .type, .name)
      ),
      web_acls: ($acls | sort_by(.scope, .region, .name))
    }
  '

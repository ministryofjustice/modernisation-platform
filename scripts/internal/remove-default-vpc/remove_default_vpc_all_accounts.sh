
#!/usr/bin/env bash

set -u
set -o pipefail

# --------------------------------------------------
# Configuration
# --------------------------------------------------

regions="eu-west-2"
ROLE_NAME="ModernisationPlatformAccess"
OUTPUT="alb_logging_audit.csv"
S3_BUCKET="modernisation-member-information"
CSV_FILE="$OUTPUT"
S3_FILE_PATH="s3://${S3_BUCKET}/data/${CSV_FILE}"
KMS_KEY_ID="alias/s3-state-bucket-multi-region"

# Preserve the original credentials used to assume roles.
ROOT_AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
ROOT_AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
ROOT_AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN:-}"

# Validate prerequisites.
for cmd in aws jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $cmd" >&2
        exit 1
    fi
done

# CSV header.
printf '%s\n' \
'"AccountId","Region","ALBName","ALBArn","Scheme","AccessLogsEnabled","S3Bucket","S3Prefix","CloudWatchMetrics","MatchingAlarms","Status"' \
> "$OUTPUT"

# --------------------------------------------------
# CSV helper
# --------------------------------------------------

csv_row() {
    jq -cn --args '$ARGS.positional | @csv' "$@"
}

# --------------------------------------------------
# Restore original credentials
# --------------------------------------------------

restore_root_credentials() {
    export AWS_ACCESS_KEY_ID="$ROOT_AWS_ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="$ROOT_AWS_SECRET_ACCESS_KEY"

    if [[ -n "$ROOT_AWS_SESSION_TOKEN" ]]; then
        export AWS_SESSION_TOKEN="$ROOT_AWS_SESSION_TOKEN"
    else
        unset AWS_SESSION_TOKEN
    fi
}

# --------------------------------------------------
# Assume role in target account
# --------------------------------------------------

getAssumeRoleCfg() {
    local account_id="$1"
    local credentials

    credentials=$(aws sts assume-role \
        --role-arn "arn:aws:iam::${account_id}:role/${ROLE_NAME}" \
        --role-session-name "alb-logging-audit" \
        --query 'Credentials' \
        --output json) || return 1

    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN

    AWS_ACCESS_KEY_ID=$(jq -r '.AccessKeyId' <<< "$credentials")
    AWS_SECRET_ACCESS_KEY=$(jq -r '.SecretAccessKey' <<< "$credentials")
    AWS_SESSION_TOKEN=$(jq -r '.SessionToken' <<< "$credentials")
}

# --------------------------------------------------
# Main account loop
# --------------------------------------------------

while IFS= read -r account_id; do

    [[ -z "$account_id" ]] && continue

    echo "========================================"
    echo "Account: $account_id"

    restore_root_credentials

    if ! getAssumeRoleCfg "$account_id"; then
        echo "ERROR: Failed to assume role in $account_id"

        csv_row "$account_id" "" "" "" "" "" "" "" "" "" \
            "ASSUME_ROLE_FAILED" >> "$OUTPUT"

        continue
    fi

    # ----------------------------------------------
    # Region loop
    # ----------------------------------------------

    for region in $regions; do

        echo "  Region: $region"

        # List Application Load Balancers only.
        if ! lbs=$(aws elbv2 describe-load-balancers \
            --region "$region" \
            --query "LoadBalancers[?Type=='application'].[LoadBalancerName,LoadBalancerArn,Scheme]" \
            --output json 2>/dev/null); then

            echo "    WARNING: Cannot list ALBs in $region"

            csv_row "$account_id" "$region" "" "" "" "" "" "" "" "" \
                "DESCRIBE_FAILED" >> "$OUTPUT"

            continue
        fi

        # Iterate through ALBs without process substitution
        # in the individual field extraction.
        while IFS= read -r lb; do

            [[ -z "$lb" ]] && continue

            lb_name=$(jq -r '.[0] // ""' <<< "$lb")
            lb_arn=$(jq -r '.[1] // ""' <<< "$lb")
            scheme=$(jq -r '.[2] // ""' <<< "$lb")

            echo "    ALB: $lb_name"

            # --------------------------------------
            # Get ALB attributes
            # --------------------------------------

            if ! attrs=$(aws elbv2 describe-load-balancer-attributes \
                --region "$region" \
                --load-balancer-arn "$lb_arn" \
                --output json 2>/dev/null); then

                echo "      ERROR: Failed to retrieve ALB attributes"

                csv_row "$account_id" "$region" "$lb_name" "$lb_arn" \
                    "$scheme" "" "" "" "Automatic" "" \
                    "ATTRIBUTES_FAILED" >> "$OUTPUT"

                continue
            fi

            logging_enabled=$(jq -r '
                [.Attributes[]? |
                 select(.Key == "access_logs.s3.enabled") |
                 .Value][0] // "unknown"
            ' <<< "$attrs")

            bucket=$(jq -r '
                [.Attributes[]? |
                 select(.Key == "access_logs.s3.bucket") |
                 .Value][0] // ""
            ' <<< "$attrs")

            prefix=$(jq -r '
                [.Attributes[]? |
                 select(.Key == "access_logs.s3.prefix") |
                 .Value][0] // ""
            ' <<< "$attrs")

            # --------------------------------------
            # Determine access logging status
            # --------------------------------------

            case "$logging_enabled" in
                true)
                    log_status="ENABLED"
                    ;;
                false)
                    log_status="DISABLED"
                    ;;
                *)
                    log_status="UNKNOWN"
                    ;;
            esac

            # --------------------------------------
            # CloudWatch metric alarms
            # --------------------------------------

            # ALB dimension format:
            # app/load-balancer-name/load-balancer-id
            lb_dimension="${lb_arn#*loadbalancer/}"

            if alarms_json=$(aws cloudwatch describe-alarms \
                --region "$region" \
                --output json 2>/dev/null); then

                alarms=$(jq -r --arg lb "$lb_dimension" '
                    [
                      .MetricAlarms[]?
                      | select(any(.Dimensions[]?;
                          .Name == "LoadBalancer" and .Value == $lb))
                      | .AlarmName
                    ] | unique | join(";")
                ' <<< "$alarms_json")

                # Composite alarms may reference metric alarms.
                composite_alarms=$(jq -r --argjson names "$(
                    jq -c --arg lb "$lb_dimension" '
                        [
                          .MetricAlarms[]?
                          | select(any(.Dimensions[]?;
                              .Name == "LoadBalancer" and .Value == $lb))
                          | .AlarmName
                        ] | unique
                    ' <<< "$alarms_json"
                )" '
                    [
                      .CompositeAlarms[]?
                      | select(any(.AlarmRuleAlarmNames[]?;
                          . as $name | ($names | index($name)) != null))
                      | .AlarmName
                    ] | unique | join(";")
                ' <<< "$alarms_json")

                if [[ -n "$composite_alarms" ]]; then
                    if [[ -n "$alarms" ]]; then
                        alarms="${alarms};${composite_alarms}"
                    else
                        alarms="$composite_alarms"
                    fi
                fi

                alarms_status="OK"
            else
                alarms=""
                alarms_status="ALARM_QUERY_FAILED"
            fi

            # --------------------------------------
            # Final status
            # --------------------------------------

            if [[ "$log_status" == "UNKNOWN" ]]; then
                final_status="LOGGING_STATUS_UNKNOWN"
            elif [[ "$alarms_status" != "OK" ]]; then
                final_status="$alarms_status"
            else
                final_status="$log_status"
            fi

            # --------------------------------------
            # Write CSV row
            # --------------------------------------

            csv_row \
                "$account_id" \
                "$region" \
                "$lb_name" \
                "$lb_arn" \
                "$scheme" \
                "$logging_enabled" \
                "$bucket" \
                "$prefix" \
                "AWS/ApplicationELB (automatic publication)" \
                "$alarms" \
                "$final_status" >> "$OUTPUT"

            echo "      Access logging : $log_status"
            echo "      S3 bucket      : ${bucket:-N/A}"
            echo "      S3 prefix      : ${prefix:-N/A}"
            echo "      Matching alarms: ${alarms:-None found}"

        done < <(jq -c '.[]' <<< "$lbs")

    done

    # Restore original credentials before next account.
    restore_root_credentials

done < <(jq -r '.account_ids[]' <<< "$ENVIRONMENT_MANAGEMENT")

restore_root_credentials

echo
echo "======================================"
echo "Audit completed."
echo "Report: $OUTPUT"
echo "Uploading CSV to S3..."

if aws s3 cp "$CSV_FILE" "$S3_FILE_PATH" \
    --sse aws:kms \
    --sse-kms-key-id "$KMS_KEY_ID"; then
    echo "Upload successful: $S3_FILE_PATH"
    rm -f "$CSV_FILE"
else
    echo "ERROR: Failed to upload CSV to S3." >&2
    exit 1
fi

echo "======================================"

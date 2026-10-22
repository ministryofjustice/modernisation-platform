
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

# Preserve original credentials, including whether each
# variable was originally set or unset.
ROOT_AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID-}"
ROOT_AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY-}"
ROOT_AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN-}"

ROOT_ACCESS_KEY_SET="${AWS_ACCESS_KEY_ID+x}"
ROOT_SECRET_KEY_SET="${AWS_SECRET_ACCESS_KEY+x}"
ROOT_SESSION_TOKEN_SET="${AWS_SESSION_TOKEN+x}"

# --------------------------------------------------
# Validate prerequisites
# --------------------------------------------------

for cmd in aws jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $cmd" >&2
        exit 1
    fi
done

if [[ -z "${ENVIRONMENT:-}" ]]; then
    echo "ERROR: ENVIRONMENT is empty or not set." >&2
    exit 1
fi

if ! jq -e '
    (.account_ids | type == "array")
    and all(.account_ids[]; type == "string")
' <<< "$ENVIRONMENT" >/dev/null; then
    echo "ERROR: ENVIRONMENT must contain a string account_ids array." >&2
    exit 1
fi

# Extract account IDs without process substitution.
account_lines=$(jq -r '.account_ids[]' <<< "$ENVIRONMENT") || {
    echo "ERROR: Unable to read account IDs." >&2
    exit 1
}

# --------------------------------------------------
# Initialise CSV
# --------------------------------------------------

printf '%s\n' \
'"AccountId","Region","ALBName","ALBArn","Scheme","AccessLogsEnabled","S3Bucket","S3Prefix","CloudWatchMetrics","MatchingAlarms","Status"' \
> "$OUTPUT" || {
    echo "ERROR: Cannot create CSV file: $OUTPUT" >&2
    exit 1
}

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

    if [[ -n "$ROOT_ACCESS_KEY_SET" ]]; then
        export AWS_ACCESS_KEY_ID="$ROOT_AWS_ACCESS_KEY_ID"
    else
        unset AWS_ACCESS_KEY_ID
    fi

    if [[ -n "$ROOT_SECRET_KEY_SET" ]]; then
        export AWS_SECRET_ACCESS_KEY="$ROOT_AWS_SECRET_ACCESS_KEY"
    else
        unset AWS_SECRET_ACCESS_KEY
    fi

    if [[ -n "$ROOT_SESSION_TOKEN_SET" ]]; then
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

    local access_key secret_key session_token

    access_key=$(jq -er '.AccessKeyId' <<< "$credentials") || return 1
    secret_key=$(jq -er '.SecretAccessKey' <<< "$credentials") || return 1
    session_token=$(jq -er '.SessionToken' <<< "$credentials") || return 1

    export AWS_ACCESS_KEY_ID="$access_key"
    export AWS_SECRET_ACCESS_KEY="$secret_key"
    export AWS_SESSION_TOKEN="$session_token"
}

# --------------------------------------------------
# Main account loop
# Uses a here-string instead of process substitution.
# --------------------------------------------------

while IFS= read -r account_id; do

    [[ -z "$account_id" ]] && continue

    echo "========================================"
    echo "Account: $account_id"

    # Ensure AssumeRole uses the original credentials.
    restore_root_credentials

    if ! getAssumeRoleCfg "$account_id"; then
        echo "ERROR: Failed to assume role in $account_id"

        csv_row \
            "$account_id" "" "" "" "" "" "" "" "" "" \
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

            csv_row \
                "$account_id" "$region" "" "" "" "" "" "" "" "" \
                "DESCRIBE_FAILED" >> "$OUTPUT"

            continue
        fi

        # Convert each ALB entry to a separate JSON line.
        # No process substitution is used.
        lb_lines=$(jq -c '.[]' <<< "$lbs") || {
            echo "    WARNING: Cannot parse ALB list."
            continue
        }

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

                csv_row \
                    "$account_id" "$region" "$lb_name" "$lb_arn" \
                    "$scheme" "" "" "" \
                    "AWS/ApplicationELB (automatic publication)" "" \
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
            # Find CloudWatch metric alarms
            # --------------------------------------

            # ALB dimension format:
            # app/load-balancer-name/load-balancer-id
            lb_dimension="${lb_arn#*loadbalancer/}"

            if alarms_json=$(aws cloudwatch describe-alarms \
                --region "$region" \
                --output json 2>/dev/null); then

                # Metric alarms associated with this ALB.
                metric_alarm_names_json=$(jq -c \
                    --arg lb "$lb_dimension" '
                    [
                        .MetricAlarms[]?
                        | select(
                            any(.Dimensions[]?;
                                .Name == "LoadBalancer"
                                and .Value == $lb)
                        )
                        | .AlarmName
                    ] | unique
                ' <<< "$alarms_json") || metric_alarm_names_json='[]'

                alarms=$(jq -r '
                    join(";")
                ' <<< "$metric_alarm_names_json")

                # Composite alarms may reference metric alarms.
                composite_alarms=$(jq -r \
                    --argjson names "$metric_alarm_names_json" '
                    [
                        .CompositeAlarms[]?
                        | . as $composite
                        | select(
                            any($names[];
                                ($composite.AlarmRule // "")
                                | contains("ALARM(\"" + . + "\")")
                            )
                        )
                        | .AlarmName
                    ] | unique | join(";")
                ' <<< "$alarms_json") || composite_alarms=""

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
            # Determine final status
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

        done <<< "$lb_lines"

    done

    # Restore credentials before processing next account.
    restore_root_credentials

done <<< "$account_lines"

# Always restore original credentials before S3 upload.
restore_root_credentials

# --------------------------------------------------
# Upload report to S3
# --------------------------------------------------

echo
echo "======================================"
echo "Audit completed."
echo "Report: $OUTPUT"
echo "Uploading CSV to S3..."

if aws s3 cp "$CSV_FILE" "$S3_FILE_PATH" \
    --sse aws:kms \
    --sse-kms-key-id "$KMS_KEY_ID"; then

    echo "Upload successful: $S3_FILE_PATH"

    # Retain the local CSV for review.
    # Uncomment the next line if you want to delete it.
    # rm -f "$CSV_FILE"

else
    echo "ERROR: Failed to upload CSV to S3." >&2
    exit 1
fi

echo "======================================"

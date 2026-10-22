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

# --------------------------------------------------
# Validate prerequisites
# --------------------------------------------------

for cmd in aws jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $cmd" >&2
        exit 1
    fi
done

# --------------------------------------------------
# CSV header
# --------------------------------------------------

printf '%s\n' \
'"AccountName","AccountId","Region","ALBName","AccessLogsEnabled","Status","S3Bucket","S3Prefix","CloudWatchMetrics","MatchingAlarms","ALBArn","Scheme"' \
> "$OUTPUT"

# --------------------------------------------------
# CSV helper
# --------------------------------------------------

csv_row() {
    jq -nr --args '$ARGS.positional | @csv' "$@"
}

get_account_name() {
    local account_id="$1"

    jq -r --arg account_id "$account_id" '
        [
            .account_ids
            | to_entries[]
            | select((.value | tostring) == $account_id)
            | .key
        ][0] // "N/A"
    ' <<< "$ENVIRONMENT_MANAGEMENT"
}

# --------------------------------------------------
# Restore original credentials
# --------------------------------------------------

restore_root_credentials() {
    if [[ -n "$ROOT_AWS_ACCESS_KEY_ID" ]]; then
        export AWS_ACCESS_KEY_ID="$ROOT_AWS_ACCESS_KEY_ID"
    else
        unset AWS_ACCESS_KEY_ID
    fi

    if [[ -n "$ROOT_AWS_SECRET_ACCESS_KEY" ]]; then
        export AWS_SECRET_ACCESS_KEY="$ROOT_AWS_SECRET_ACCESS_KEY"
    else
        unset AWS_SECRET_ACCESS_KEY
    fi

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

    AWS_ACCESS_KEY_ID=$(jq -er '.AccessKeyId' <<< "$credentials") ||
        return 1

    AWS_SECRET_ACCESS_KEY=$(jq -er '.SecretAccessKey' <<< "$credentials") ||
        return 1

    AWS_SESSION_TOKEN=$(jq -er '.SessionToken' <<< "$credentials") ||
        return 1
}

# --------------------------------------------------
# Main account loop
# --------------------------------------------------

while IFS= read -r account_id; do

    [[ -z "$account_id" ]] && continue

    account_name=$(get_account_name "$account_id")
    account_name=${account_name:-N/A}

    echo "========================================"
    echo "Account Name: $account_name"
    echo "Account ID  : $account_id"

    # Start each account with the original credentials.
    restore_root_credentials

    if ! getAssumeRoleCfg "$account_id"; then
        echo "ERROR: Failed to assume role in $account_id" >&2

        csv_row \
            "$account_name" \
            "$account_id" \
            "" "" "" \
            "ASSUME_ROLE_FAILED" \
            "" "" "" "" "" "" >> "$OUTPUT"

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

            echo "WARNING: Cannot list ALBs in $region" >&2

            csv_row \
                "$account_name" \
                "$account_id" \
                "$region" \
                "" "" \
                "DESCRIBE_FAILED" \
                "" "" "" "" "" "" >> "$OUTPUT"

            continue
        fi

        # ------------------------------------------
        # Iterate through ALBs
        # ------------------------------------------

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

                echo "ERROR: Failed to retrieve ALB attributes" >&2

                csv_row \
                    "$account_name" \
                    "$account_id" \
                    "$region" \
                    "$lb_name" \
                    "" \
                    "ATTRIBUTES_FAILED" \
                    "" "" \
                    "Automatic" \
                    "" \
                    "$lb_arn" \
                    "$scheme" >> "$OUTPUT"

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
            # CloudWatch metric and composite alarms
            # --------------------------------------

            # ALB dimension format:
            # app/load-balancer-name/load-balancer-id
            lb_dimension="${lb_arn#*loadbalancer/}"

            if alarms_json=$(aws cloudwatch describe-alarms \
                --region "$region" \
                --output json 2>/dev/null); then

                # Find metric alarms matching this ALB.
                metric_alarms_json=$(jq -c --arg lb "$lb_dimension" '
                    [
                        .MetricAlarms[]?
                        | select(any(.Dimensions[]?;
                            .Name == "LoadBalancer" and .Value == $lb))
                        | .AlarmName
                    ] | unique
                ' <<< "$alarms_json")

                alarms=$(jq -r 'join(";")' <<< "$metric_alarms_json")

                # Identify composite alarms that reference matching
                # metric alarms. AlarmRule is an expression string.
                matching_composites=$(jq -r \
                    --argjson names "$metric_alarms_json" '
                    [
                        .CompositeAlarms[]?
                        | . as $composite
                        | select(
                            any($names[];
                                . as $name
                                | ($composite.AlarmRule // "")
                                | contains($name)
                            )
                        )
                        | .AlarmName
                    ] | unique | join(";")
                ' <<< "$alarms_json")

                if [[ -n "$matching_composites" ]]; then
                    if [[ -n "$alarms" ]]; then
                        alarms="${alarms};${matching_composites}"
                    else
                        alarms="$matching_composites"
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
            # Write CSV row in requested column order
            # --------------------------------------

            csv_row \
                "$account_name" \
                "$account_id" \
                "$region" \
                "$lb_name" \
                "$logging_enabled" \
                "$final_status" \
                "$bucket" \
                "$prefix" \
                "AWS/ApplicationELB (automatic publication)" \
                "$alarms" \
                "$lb_arn" \
                "$scheme" >> "$OUTPUT"

            echo "      Access logging : $log_status"
            echo "      S3 bucket      : ${bucket:-N/A}"
            echo "      S3 prefix      : ${prefix:-N/A}"
            echo "      Matching alarms: ${alarms:-None found}"

        done < <(jq -c '.[]' <<< "$lbs")

    done

    # Restore original credentials before the next account.
    restore_root_credentials

done < <(jq -r '.account_ids[]' <<< "$ENVIRONMENT_MANAGEMENT")

# Restore original credentials before uploading.
restore_root_credentials

# --------------------------------------------------
# Preview and upload CSV to S3
# --------------------------------------------------

echo
echo "========================================"
echo "Audit completed."
echo "Report: $OUTPUT"
echo
echo "CSV preview:"
head -n 5 "$CSV_FILE"
echo
echo "Uploading CSV to S3..."

if aws s3 cp "$CSV_FILE" "$S3_FILE_PATH" \
    --sse aws:kms \
    --sse-kms-key-id "$KMS_KEY_ID"; then

    echo "Upload successful: $S3_FILE_PATH"

    # Remove the local report only after successful upload.
    rm -f "$CSV_FILE"
else
    echo "ERROR: Failed to upload CSV to S3." >&2
    echo "Local report retained at: $CSV_FILE" >&2
    exit 1
fi

echo "========================================"
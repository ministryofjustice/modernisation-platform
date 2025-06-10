#!/bin/bash

REGION="eu-west-2"
INSIGHT_NAME="FindingCountsBySeverity"

# Function to create insight if it doesn't exist
create_or_get_insight() {
    
    # Check if insight already exists
    INSIGHT_ARN=$(aws securityhub get-insights --region "$REGION" \
        --query "Insights[?Name=='$INSIGHT_NAME'].InsightArn" \
        --output text)
    if [ -z "$INSIGHT_ARN" ]; then
        echo "Creating new Security Hub insight..."
        INSIGHT_ARN=$(aws securityhub create-insight --region "$REGION" \
            --name "$INSIGHT_NAME" \
            --filters '{"RecordState": [{"Value": "ACTIVE", "Comparison": "EQUALS"}]}' \
            --group-by-attribute "SeverityLabel" \
            --query "InsightArn" \
            --output text)
    fi
    get_severity_counts "$INSIGHT_ARN"
    
}

# Function to get severity counts
get_severity_counts() {
    local insight_arn=$1
    # Fetching current severity counts
    aws securityhub get-insight-results \
        --region "$REGION" \
        --insight-arn "$insight_arn" \
        --query "InsightResults.ResultValues" \
        --output json | jq -r ' map({(.GroupByAttributeValue): .Count}) | add as $all | ["CRITICAL","HIGH","MEDIUM","LOW"][] as $sev | "\($sev): \($all[$sev] // 0)"'
}

# Checking/creating Security Hub insight in $REGION
create_or_get_insight
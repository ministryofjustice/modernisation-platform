#!/bin/bash
set -euo pipefail

# PagerDuty Status Page Subscription Manager
# This script synchronizes email subscriptions to a PagerDuty status page
# It will add new emails and remove old ones to match the desired list
#
# Environment Variables Required:
#   PAGERDUTY_TOKEN   - PagerDuty API token
#   STATUS_PAGE_ID    - PagerDuty status page ID
#   SUBSCRIBER_EMAILS - JSON array of email addresses to subscribe
#
# This script is called by Terraform from terraform/pagerduty/status-page-subscriptions.tf

# Configuration
API_BASE="https://api.pagerduty.com"
STATUS_PAGE_ID="${STATUS_PAGE_ID}"
TOKEN="${PAGERDUTY_TOKEN}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse desired emails from JSON array
DESIRED_EMAILS=$(echo "${SUBSCRIBER_EMAILS}" | jq -r '.[]' | sort)

echo -e "${BLUE}🔄 PagerDuty Status Page Subscription Manager${NC}"
echo "Status Page ID: ${STATUS_PAGE_ID}"
echo ""

# Function to get all existing subscribers
get_existing_subscribers() {
    local offset=0
    local limit=100
    local more=true
    local all_subscribers=""
    
    while [ "$more" = "true" ]; do
        echo "  Fetching page at offset ${offset}..." >&2
        local response=$(curl -s -X GET \
            "${API_BASE}/status_pages/${STATUS_PAGE_ID}/subscriptions?limit=${limit}&offset=${offset}" \
            -H "Authorization: Token token=${TOKEN}" \
            -H "Accept: application/vnd.pagerduty+json;version=2")
        
        # Check if response is valid JSON
        if ! echo "$response" | jq empty 2>/dev/null; then
            echo -e "${RED}Error: Invalid API response${NC}" >&2
            echo "Response: $response" >&2
            exit 1
        fi
        
        # Extract email subscribers from this page (ONLY status page level, not services/posts)
        local page_subscribers=$(echo "$response" | jq -r '.subscriptions[]? | select(.channel == "email" and .subscribable_object.type == "status_page") | .contact + "|" + .id' 2>/dev/null || echo "")
        all_subscribers="${all_subscribers}${page_subscribers}"$'\n'
        
        # Check if there are more pages
        more=$(echo "$response" | jq -r '.more // false')
        echo "  Found $(echo "$page_subscribers" | grep -v '^$' | wc -l | tr -d ' ') subscribers on this page. More pages: ${more}" >&2
        offset=$((offset + limit))
    done
    
    echo "$all_subscribers"
}

# Get existing subscribers
echo "📊 Fetching current subscribers..."
EXISTING_RAW=$(get_existing_subscribers)
EXISTING_EMAILS=$(echo "$EXISTING_RAW" | grep -v '^$' | cut -d'|' -f1 | sort || echo "")

# Handle empty existing emails
if [ -z "$EXISTING_EMAILS" ]; then
    EXISTING_EMAILS=""
fi

# Calculate differences
TO_ADD=$(comm -23 <(echo "$DESIRED_EMAILS") <(echo "$EXISTING_EMAILS") || echo "$DESIRED_EMAILS")
TO_REMOVE=$(comm -13 <(echo "$DESIRED_EMAILS") <(echo "$EXISTING_EMAILS") || echo "")
UNCHANGED=$(comm -12 <(echo "$DESIRED_EMAILS") <(echo "$EXISTING_EMAILS") || echo "")

# Count items
COUNT_DESIRED=$(echo "$DESIRED_EMAILS" | grep -c . || true)
COUNT_EXISTING=$(echo "$EXISTING_EMAILS" | grep -c . || true)
COUNT_TO_ADD=$(echo "$TO_ADD" | grep -c . || true)
COUNT_TO_REMOVE=$(echo "$TO_REMOVE" | grep -c . || true)
COUNT_UNCHANGED=$(echo "$UNCHANGED" | grep -c . || true)

echo ""
echo -e "${BLUE}📊 Subscription Analysis:${NC}"
echo "   Total desired: ${COUNT_DESIRED}"
echo "   Currently subscribed: ${COUNT_EXISTING}"
echo "   To add: ${COUNT_TO_ADD}"
echo "   To remove: ${COUNT_TO_REMOVE}"
echo "   Unchanged: ${COUNT_UNCHANGED}"
echo ""

# Track success/failure
ADDED=0
REMOVED=0
ERRORS=0

# Add new subscriptions
if [ -n "$TO_ADD" ]; then
    echo -e "${GREEN}➕ Adding new subscribers:${NC}"
    while IFS= read -r email; do
        [ -z "$email" ] && continue
        
        response=$(curl -s -w "\n%{http_code}" -X POST \
            "${API_BASE}/status_pages/${STATUS_PAGE_ID}/subscriptions" \
            -H "Authorization: Token token=${TOKEN}" \
            -H "Content-Type: application/json" \
            -H "Accept: application/vnd.pagerduty+json;version=2" \
            -d "{
                \"subscription\": {
                    \"type\": \"status_page_subscription\",
                    \"channel\": \"email\",
                    \"contact\": \"${email}\",
                    \"status_page\": {
                        \"id\": \"${STATUS_PAGE_ID}\",
                        \"type\": \"status_page\"
                    },
                    \"subscribable_object\": {
                        \"id\": \"${STATUS_PAGE_ID}\",
                        \"type\": \"status_page\"
                    }
                }
            }")
        
        http_code=$(echo "$response" | tail -n1)
        response_body=$(echo "$response" | sed '$d')
        
        if [ "$http_code" = "201" ]; then
            echo -e "   ${GREEN}✓${NC} Subscribed: ${email}"
            ((ADDED++))
        else
            echo -e "   ${YELLOW}⚠${NC} Failed to subscribe: ${email} (HTTP ${http_code})"
            echo -e "       API Response: ${response_body}" >&2
            # Don't fail on individual email errors - log and continue
        fi
        
        # Rate limiting: sleep briefly between API calls to avoid hitting rate limits
        sleep 0.5
    done <<< "$TO_ADD"
fi

# Remove old subscriptions
if [ -n "$TO_REMOVE" ]; then
    echo ""
    echo -e "${YELLOW}➖ Removing old subscribers:${NC}"
    while IFS= read -r email; do
        [ -z "$email" ] && continue
        
        # Get subscription ID for this email
        subscription_id=$(echo "$EXISTING_RAW" | grep "^${email}|" | cut -d'|' -f2)
        
        if [ -z "$subscription_id" ]; then
            echo -e "   ${RED}✗${NC} Could not find subscription ID for: ${email}"
            ((ERRORS++))
            continue
        fi
        
        http_code=$(curl -s -w "%{http_code}" -o /dev/null -X DELETE \
            "${API_BASE}/status_pages/${STATUS_PAGE_ID}/subscriptions/${subscription_id}" \
            -H "Authorization: Token token=${TOKEN}" \
            -H "Accept: application/vnd.pagerduty+json;version=2")
        
        if [ "$http_code" = "204" ]; then
            echo -e "   ${GREEN}✓${NC} Unsubscribed: ${email}"
            ((REMOVED++))
        else
            echo -e "   ${RED}✗${NC} Failed to unsubscribe: ${email} (HTTP ${http_code})"
            ((ERRORS++))
        fi
    done <<< "$TO_REMOVE"
fi

# No changes needed
if [ -z "$TO_ADD" ] && [ -z "$TO_REMOVE" ]; then
    echo -e "${GREEN}✓ All subscribers are already in sync. No changes needed.${NC}"
fi

# Summary
echo ""
echo "============================================================"
echo -e "${BLUE}📋 Summary:${NC}"
echo -e "   ${GREEN}✓ Added: ${ADDED}${NC}"
echo -e "   ${GREEN}✓ Removed: ${REMOVED}${NC}"
echo -e "   ${GREEN}✓ Unchanged: ${COUNT_UNCHANGED}${NC}"
if [ $ERRORS -gt 0 ]; then
    echo -e "   ${RED}✗ Errors: ${ERRORS}${NC}"
fi
echo "============================================================"

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Some operations failed. Please check the logs above.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Synchronization complete!${NC}"

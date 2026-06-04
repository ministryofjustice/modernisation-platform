#!/bin/bash

# Script to remove all security group rules from all security groups in an AWS environment
# Usage: Export AWS credentials and run the script
# Example:
#   export AWS_ACCESS_KEY_ID="your_access_key_id"
#   export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
#   export AWS_SESSION_TOKEN="your_session_token"
#   ./scripts/internal/quarantine-security-groups.sh

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Timestamp for backup file
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./sg_quarantine_backups"
BACKUP_FILE="${BACKUP_DIR}/sg_backup_${TIMESTAMP}.json"
BACKUP_TEXT_FILE="${BACKUP_DIR}/sg_backup_${TIMESTAMP}.txt"
LOG_FILE="${BACKUP_DIR}/sg_quarantine_${TIMESTAMP}.log"

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Redirect all output to both console and log file
exec > >(tee -a "${LOG_FILE}") 2>&1

echo -e "${BLUE}=== AWS Security Group Quarantine Script ===${NC}"
echo "Started at: $(date)"
echo ""

# Function to log messages
log() {
    echo -e "${1}"
}

# Function to exit on error
error_exit() {
    log "${RED}ERROR: ${1}${NC}"
    exit 1
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    error_exit "AWS CLI is not installed. Please install it first."
fi

# Check if jq is installed (for JSON processing)
if ! command -v jq &> /dev/null; then
    error_exit "jq is not installed. Please install it first (brew install jq on macOS)."
fi

# Verify AWS credentials are configured
log "${YELLOW}Verifying AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    error_exit "AWS credentials are not configured or invalid. Please export AWS credentials first."
fi

# Get account information
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ACCOUNT_ALIAS=$(aws iam list-account-aliases --query 'AccountAliases[0]' --output text 2>/dev/null || echo "No alias set")
AWS_REGION=$(aws configure get region || echo "us-east-1")
CALLER_IDENTITY=$(aws sts get-caller-identity --query Arn --output text)

log "${GREEN}AWS Account Details:${NC}"
log "  Account ID: ${ACCOUNT_ID}"
log "  Account Alias: ${ACCOUNT_ALIAS}"
log "  Region: ${AWS_REGION}"
log "  Caller Identity: ${CALLER_IDENTITY}"
log ""

# Warning message
log "${RED}═══════════════════════════════════════════════════════════════════════${NC}"
log "${RED}                         WARNING                                       ${NC}"
log "${RED}  This script will REMOVE ALL RULES from ALL Security Groups           ${NC}"
log "${RED}  This is a DESTRUCTIVE operation for network quarantine               ${NC}"
log "${RED}  Backup file: ${BACKUP_FILE}${NC}"
log "${RED}═══════════════════════════════════════════════════════════════════════${NC}"
log ""

# First confirmation
read -p "Do you want to proceed with listing security groups? (yes/no): " CONFIRM1
if [ "$CONFIRM1" != "yes" ]; then
    log "${YELLOW}Operation cancelled by user.${NC}"
    exit 0
fi

# Get all security groups
log "${YELLOW}Retrieving all security groups...${NC}"
SECURITY_GROUPS=$(aws ec2 describe-security-groups --output json)

if [ -z "$SECURITY_GROUPS" ]; then
    error_exit "Failed to retrieve security groups."
fi

# Count security groups
SG_COUNT=$(echo "$SECURITY_GROUPS" | jq '.SecurityGroups | length')
log "${GREEN}Found ${SG_COUNT} security groups${NC}"
log ""

# Display security groups with their rules
log "${BLUE}Security Groups to be affected:${NC}"
printf "%-22s %-60s %-23s %8s %8s\n" "Group ID" "Name" "VPC ID" "Ingress" "Egress"
printf "%-22s %-60s %-23s %8s %8s\n" "--------" "----" "------" "-------" "------"
echo "$SECURITY_GROUPS" | jq -r '.SecurityGroups[] | 
    [.GroupId, .GroupName, (.VpcId // "EC2-Classic"), (.IpPermissions | length | tostring), (.IpPermissionsEgress | length | tostring)] | 
    @tsv' | while IFS=$'\t' read -r gid gname vpc ingress egress; do
    printf "%-22s %-60s %-23s %8s %8s\n" "$gid" "$gname" "$vpc" "$ingress" "$egress"
done
log ""

# Check if there are any rules to remove
TOTAL_RULES=$(echo "$SECURITY_GROUPS" | jq '[.SecurityGroups[] | (.IpPermissions | length) + (.IpPermissionsEgress | length)] | add // 0')
if [ "$TOTAL_RULES" -eq 0 ]; then
    log "${GREEN}✓ No security group rules found to remove.${NC}"
    log "${GREEN}All security groups are already empty (quarantined state).${NC}"
    log ""
    log "Completed at: $(date)"
    exit 0
fi

log "${YELLOW}Total rules to remove: ${TOTAL_RULES}${NC}"
log ""

# Save full backup
log "${YELLOW}Backing up all security group rules...${NC}"
echo "$SECURITY_GROUPS" > "$BACKUP_FILE"

# Create human-readable text backup
{
    echo "AWS Security Group Backup"
    echo "========================="
    echo "Account: ${ACCOUNT_ALIAS} (${ACCOUNT_ID})"
    echo "Region: ${AWS_REGION}"
    echo "Timestamp: $(date)"
    echo ""
    echo "=================================================================================================="
    echo ""
    
    echo "$SECURITY_GROUPS" | jq -c '.SecurityGroups[]' | while read -r sg; do
        GROUP_ID=$(echo "$sg" | jq -r '.GroupId')
        GROUP_NAME=$(echo "$sg" | jq -r '.GroupName')
        VPC_ID=$(echo "$sg" | jq -r '.VpcId // "EC2-Classic"')
        DESCRIPTION=$(echo "$sg" | jq -r '.Description')
        
        echo "Security Group: $GROUP_NAME ($GROUP_ID)"
        echo "VPC: $VPC_ID"
        echo "Description: $DESCRIPTION"
        echo ""
        
        # Ingress Rules
        echo "  INGRESS RULES:"
        INGRESS_COUNT=$(echo "$sg" | jq '.IpPermissions | length')
        if [ "$INGRESS_COUNT" -eq 0 ]; then
            echo "    (none)"
        else
            echo "$sg" | jq -r '.IpPermissions[] | 
                "    Protocol: \(.IpProtocol) | Port: \(if .FromPort then "\(.FromPort)-\(.ToPort)" else "ALL" end) | Source: \(
                    if (.IpRanges | length) > 0 then (.IpRanges | map(.CidrIp) | join(", "))
                    elif (.Ipv6Ranges | length) > 0 then (.Ipv6Ranges | map(.CidrIpv6) | join(", "))
                    elif (.UserIdGroupPairs | length) > 0 then (.UserIdGroupPairs | map(.GroupId) | join(", "))
                    else "N/A" end
                )"'
        fi
        echo ""
        
        # Egress Rules
        echo "  EGRESS RULES:"
        EGRESS_COUNT=$(echo "$sg" | jq '.IpPermissionsEgress | length')
        if [ "$EGRESS_COUNT" -eq 0 ]; then
            echo "    (none)"
        else
            echo "$sg" | jq -r '.IpPermissionsEgress[] | 
                "    Protocol: \(.IpProtocol) | Port: \(if .FromPort then "\(.FromPort)-\(.ToPort)" else "ALL" end) | Destination: \(
                    if (.IpRanges | length) > 0 then (.IpRanges | map(.CidrIp) | join(", "))
                    elif (.Ipv6Ranges | length) > 0 then (.Ipv6Ranges | map(.CidrIpv6) | join(", "))
                    elif (.UserIdGroupPairs | length) > 0 then (.UserIdGroupPairs | map(.GroupId) | join(", "))
                    else "N/A" end
                )"'
        fi
        echo ""
        echo "=================================================================================================="
        echo ""
    done
} > "$BACKUP_TEXT_FILE"

log "${GREEN}JSON backup: ${BACKUP_FILE}${NC}"
log "${GREEN}Text backup: ${BACKUP_TEXT_FILE}${NC}"
log ""

# Second confirmation
log "${RED}FINAL CONFIRMATION REQUIRED${NC}"
log "You are about to quarantine security groups in:"
log "  Account: ${ACCOUNT_ALIAS} (${ACCOUNT_ID})"
log "  Region: ${AWS_REGION}"
log ""
read -p "Type 'confirm' to proceed with removing all security group rules: " FINAL_CONFIRM
if [ "$FINAL_CONFIRM" != "confirm" ]; then
    log "${YELLOW}Operation cancelled by user.${NC}"
    exit 0
fi

log ""
log "${RED}Starting security group quarantine process...${NC}"
log ""

# Counters
TOTAL_PROCESSED=0
TOTAL_INGRESS_REMOVED=0
TOTAL_EGRESS_REMOVED=0
FAILED_SG=0

# Process each security group
while read -r sg; do
    GROUP_ID=$(echo "$sg" | jq -r '.GroupId')
    GROUP_NAME=$(echo "$sg" | jq -r '.GroupName')
    INGRESS_RULES=$(echo "$sg" | jq '.IpPermissions')
    EGRESS_RULES=$(echo "$sg" | jq '.IpPermissionsEgress')
    INGRESS_COUNT=$(echo "$INGRESS_RULES" | jq 'length')
    EGRESS_COUNT=$(echo "$EGRESS_RULES" | jq 'length')
    
    log "${BLUE}Processing: ${GROUP_ID} (${GROUP_NAME})${NC}"
    
    # Remove ingress rules
    if [ "$INGRESS_COUNT" -gt 0 ]; then
        log "  Removing ${INGRESS_COUNT} ingress rule(s)..."
        if aws ec2 revoke-security-group-ingress \
            --group-id "$GROUP_ID" \
            --ip-permissions "$INGRESS_RULES" 2>&1; then
            log "${GREEN}  ✓ Removed ${INGRESS_COUNT} ingress rule(s)${NC}"
            TOTAL_INGRESS_REMOVED=$((TOTAL_INGRESS_REMOVED + INGRESS_COUNT))
        else
            log "${RED}  ✗ Failed to remove ingress rules${NC}"
            FAILED_SG=$((FAILED_SG + 1))
        fi
    else
        log "  No ingress rules to remove"
    fi
    
    # Remove egress rules (but keep default VPC egress if desired)
    if [ "$EGRESS_COUNT" -gt 0 ]; then
        log "  Removing ${EGRESS_COUNT} egress rule(s)..."
        if aws ec2 revoke-security-group-egress \
            --group-id "$GROUP_ID" \
            --ip-permissions "$EGRESS_RULES" 2>&1; then
            log "${GREEN}  ✓ Removed ${EGRESS_COUNT} egress rule(s)${NC}"
            TOTAL_EGRESS_REMOVED=$((TOTAL_EGRESS_REMOVED + EGRESS_COUNT))
        else
            log "${RED}  ✗ Failed to remove egress rules${NC}"
            FAILED_SG=$((FAILED_SG + 1))
        fi
    else
        log "  No egress rules to remove"
    fi
    
    TOTAL_PROCESSED=$((TOTAL_PROCESSED + 1))
    log ""
done < <(echo "$SECURITY_GROUPS" | jq -c '.SecurityGroups[]')

# Final summary
log "${GREEN}=== Quarantine Summary ===${NC}"
log "Account: ${ACCOUNT_ALIAS} (${ACCOUNT_ID})"
log "Region: ${AWS_REGION}"
log "Security Groups Processed: ${TOTAL_PROCESSED}"
log "Total Ingress Rules Removed: ${TOTAL_INGRESS_REMOVED}"
log "Total Egress Rules Removed: ${TOTAL_EGRESS_REMOVED}"
log "Failed Operations: ${FAILED_SG}"
log ""
log "JSON Backup: ${BACKUP_FILE}"
log "Text Backup: ${BACKUP_TEXT_FILE}"
log "Log File: ${LOG_FILE}"
log ""
log "Completed at: $(date)"

if [ "$FAILED_SG" -gt 0 ]; then
    log "${YELLOW}Warning: Some security groups failed to update. Check the log for details.${NC}"
    exit 1
fi

log "${GREEN}Security group quarantine completed successfully.${NC}"
log "${YELLOW}Note: To restore rules, use the backup files:${NC}"
log "${YELLOW}  JSON: ${BACKUP_FILE}${NC}"
log "${YELLOW}  Text: ${BACKUP_TEXT_FILE}${NC}"
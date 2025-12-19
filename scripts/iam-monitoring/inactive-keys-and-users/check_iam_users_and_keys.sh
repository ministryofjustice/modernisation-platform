#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# IAM access key & user hygiene scanner + enforcer
#
# Lifecycle (for BOTH keys and users) based on inactivity days:
#   - >= *_NOTIFY_DAYS   and < *_DISABLE_DAYS -> notify (via GOV.UK Notify)
#   - >= *_DISABLE_DAYS  and < *_DELETE_DAYS  -> disable
#   - >= *_DELETE_DAYS                         -> delete
#
# Thresholds (days) – override via env as needed:
#   KEY_NOTIFY_DAYS   (default 0  – for testing; set 30 in prod)
#   KEY_DISABLE_DAYS  (default 60)
#   KEY_DELETE_DAYS   (default 90)
#   USER_NOTIFY_DAYS  (default 0  – for testing; set 30 in prod)
#   USER_DISABLE_DAYS (default 60)
#   USER_DELETE_DAYS  (default 90)
#
# GOV.UK Notify (per-user emails, non-dry-run only):
#   GOV_UK_NOTIFY_API_KEY   – Notify API key
#   TEMPLATE_ID             – template ID, must support ((username))
#   EXPECTED_TEMPLATE_VERSION (optional safety check)
#
#   The recipient email address is taken from the IAM user tag:
#     Key:   infrastructure-support
#     Value: email address (e.g. team@justice.gov.uk)
#
# DRY RUN:
#   - If first arg is "--dry-run" or "dry-run", OR env DRY_RUN=true:
#       * No mutating AWS calls are made (disable/delete)
#       * No GOV.UK Notify emails are sent
#       * Classification + output files are still produced
# ------------------------------------------------------------------------------

# --- dry-run handling ---------------------------------------------------------
DRY_RUN="${DRY_RUN:-false}"
if [[ "${1:-}" == "--dry-run" || "${1:-}" == "dry-run" ]]; then
  DRY_RUN="true"
  shift || true
fi

if [[ "$DRY_RUN" == "true" ]]; then
  echo ">>> RUNNING IN DRY-RUN MODE: no changes will be made, no emails sent"
else
  echo ">>> RUNNING IN LIVE MODE: changes WILL be made to IAM keys/users"
fi

# --- thresholds ---------------------------------------------------------------
: "${KEY_NOTIFY_DAYS:=0}"
: "${KEY_DISABLE_DAYS:=60}"
: "${KEY_DELETE_DAYS:=90}"
: "${USER_NOTIFY_DAYS:=0}"
: "${USER_DISABLE_DAYS:=60}"
: "${USER_DELETE_DAYS:=90}"

IAM_USER_PATH_PREFIX="${IAM_USER_PATH_PREFIX:-}"
IAM_USER_TAG_KEY="${IAM_USER_TAG_KEY:-}"      # optional filter
IAM_USER_TAG_VALUE="${IAM_USER_TAG_VALUE:-}"  # optional filter value

# Tag used to find per-user email
IAM_NOTIFY_EMAIL_TAG_KEY="${IAM_NOTIFY_EMAIL_TAG_KEY:-infrastructure-support}"

echo "Using key thresholds (days):"
echo "  notify : ${KEY_NOTIFY_DAYS}"
echo "  disable: ${KEY_DISABLE_DAYS}"
echo "  delete : ${KEY_DELETE_DAYS}"
echo "Using user thresholds (days):"
echo "  notify : ${USER_NOTIFY_DAYS}"
echo "  disable: ${USER_DISABLE_DAYS}"
echo "  delete : ${USER_DELETE_DAYS}"
echo "Optional filters:"
echo "  IAM_USER_PATH_PREFIX    = ${IAM_USER_PATH_PREFIX:-<none>}"
echo "  IAM_USER_TAG_KEY        = ${IAM_USER_TAG_KEY:-<none>}"
echo "  IAM_USER_TAG_VALUE      = ${IAM_USER_TAG_VALUE:-<none>}"
echo "Notify email tag key      = ${IAM_NOTIFY_EMAIL_TAG_KEY}"

# Clean old outputs
rm -f iam_hygiene.json \
      keys_notify.list keys_disable.list keys_delete.list \
      users_notify.list users_disable.list users_delete.list \
      .iam_hygiene_tmp.json || true

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed." >&2
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: aws CLI is required but not installed." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required but not installed." >&2
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null || echo 'unknown')"
export ACCOUNT_ID
echo "Scanning IAM users in account: ${ACCOUNT_ID}"

# Cross-platform days-since helper using python3 (works on macOS & Linux)
days_since() {
  local iso="$1"
  if [[ -z "$iso" || "$iso" == "null" ]]; then
    echo ""
    return
  fi

  python3 - "$iso" << 'EOF'
import sys, datetime

iso = sys.argv[1]
if not iso or iso == "null":
    print("")
    sys.exit(0)

# Normalise Z → +00:00 for fromisoformat
iso = iso.replace("Z", "+00:00")

dt = None
for fmt in (None, "%Y-%m-%dT%H:%M:%S%z"):
    try:
        if fmt is None:
            dt = datetime.datetime.fromisoformat(iso)
        else:
            dt = datetime.datetime.strptime(iso, fmt)
        break
    except Exception:
        continue

if dt is None:
    print("")
    sys.exit(0)

if dt.tzinfo is None:
    dt = dt.replace(tzinfo=datetime.timezone.utc)

now = datetime.datetime.now(datetime.timezone.utc)
diff = (now - dt).total_seconds()
if diff < 0:
    diff = 0
days = int(diff // 86400)
print(days)
EOF
}

append_json() {
  local json="$1"
  printf '%s\n' "$json" >> .iam_hygiene_tmp.json
}

MARKER=""
MORE="true"

# DISCOVERY + CLASSIFICATION --------------------------------------------

while [[ "$MORE" == "true" ]]; do
  if [[ -n "$MARKER" ]]; then
    RESP="$(aws iam list-users --marker "$MARKER" --output json)"
  else
    RESP="$(aws iam list-users --output json)"
  fi

  USERS_JSON="$(echo "$RESP" | jq -c '.Users[]')"

  IS_TRUNCATED="$(echo "$RESP" | jq -r '.IsTruncated // false')"
  if [[ "$IS_TRUNCATED" == "true" ]]; then
    MARKER="$(echo "$RESP" | jq -r '.Marker')"
    [[ "$MARKER" == "null" ]] && MORE="false" || MORE="true"
  else
    MORE="false"
  fi

  while IFS= read -r user; do
    [[ -z "$user" ]] && continue

    USER_NAME="$(echo "$user" | jq -r '.UserName')"
    USER_PATH="$(echo "$user" | jq -r '.Path')"
    USER_CREATE_DATE="$(echo "$user" | jq -r '.CreateDate')"
    USER_AGE_DAYS="$(days_since "$USER_CREATE_DATE")"
    USER_PASSWORD_LAST_USED="$(echo "$user" | jq -r '.PasswordLastUsed // empty')"

    echo "Processing user: ${USER_NAME}"

    # Fetch tags for this user (for filtering AND for notify email)
    USER_TAGS_JSON="$(aws iam list-user-tags --user-name "$USER_NAME" --output json 2>/dev/null || echo '{"Tags":[]}')"

    # Optional filter by tag
    if [[ -n "$IAM_USER_TAG_KEY" ]]; then
      MATCHING_TAG="$(echo "$USER_TAGS_JSON" | jq -r --arg k "$IAM_USER_TAG_KEY" --arg v "$IAM_USER_TAG_VALUE" '
        .Tags[]? | select(.Key == $k and (.Value == $v or $v == "")) | .Key
      ' || true)"
      if [[ -z "$MATCHING_TAG" ]]; then
        continue
      fi
    fi

    # Optional path filter
    if [[ -n "$IAM_USER_PATH_PREFIX" && "$USER_PATH" != "$IAM_USER_PATH_PREFIX"* ]]; then
      continue
    fi

    # Extract per-user notify email from tag, if present
    USER_NOTIFY_EMAIL="$(echo "$USER_TAGS_JSON" | jq -r --arg k "$IAM_NOTIFY_EMAIL_TAG_KEY" '
      .Tags[]? | select(.Key == $k) | .Value
    ' | head -n1 || true)"

    if [[ -z "$USER_NOTIFY_EMAIL" || "$USER_NOTIFY_EMAIL" == "null" ]]; then
      USER_NOTIFY_EMAIL=""
    fi

    KEYS_RESP="$(aws iam list-access-keys --user-name "$USER_NAME" --output json)"
    KEYS_JSON="$(echo "$KEYS_RESP" | jq -c '.AccessKeyMetadata[]?')"

    USER_HAS_KEYS="false"
    USER_LAST_ACTIVITY_DATE=""
    USER_LAST_ACTIVITY_DAYS=""
    USER_LAST_ACTIVITY_DAYS_NUM=""   # numeric tracker for most recent key usage

    # ----- per-key classification --------------------------------------------
    while IFS= read -r key_meta; do
      [[ -z "$key_meta" ]] && continue
      USER_HAS_KEYS="true"

      ACCESS_KEY_ID="$(echo "$key_meta" | jq -r '.AccessKeyId')"
      KEY_STATUS="$(echo "$key_meta" | jq -r '.Status')"
      KEY_CREATE_DATE="$(echo "$key_meta" | jq -r '.CreateDate')"
      KEY_AGE_DAYS="$(days_since "$KEY_CREATE_DATE")"

      LAST_USED_RESP="$(aws iam get-access-key-last-used --access-key-id "$ACCESS_KEY_ID" --output json)"
      KEY_LAST_USED_DATE="$(echo "$LAST_USED_RESP" | jq -r '.AccessKeyLastUsed.LastUsedDate // empty')"
      KEY_LAST_USED_SERVICE="$(echo "$LAST_USED_RESP" | jq -r '.AccessKeyLastUsed.ServiceName // empty')"
      KEY_LAST_USED_REGION="$(echo "$LAST_USED_RESP" | jq -r '.AccessKeyLastUsed.Region // empty')"

      if [[ -n "$KEY_LAST_USED_DATE" ]]; then
        KEY_LAST_USED_DAYS="$(days_since "$KEY_LAST_USED_DATE")"
        INACTIVE_DAYS="$KEY_LAST_USED_DAYS"
      else
        KEY_LAST_USED_DAYS=""
        INACTIVE_DAYS="$KEY_AGE_DAYS"   # never used -> age as inactivity
      fi

      # Track user-level last activity based on most recent key usage
      if [[ -n "$KEY_LAST_USED_DATE" && -n "${KEY_LAST_USED_DAYS:-}" ]]; then
        if [[ -z "$USER_LAST_ACTIVITY_DATE" ]]; then
          USER_LAST_ACTIVITY_DATE="$KEY_LAST_USED_DATE"
          USER_LAST_ACTIVITY_DAYS_NUM="$KEY_LAST_USED_DAYS"
        else
          # smaller days_since = more recent activity
          if (( KEY_LAST_USED_DAYS < USER_LAST_ACTIVITY_DAYS_NUM )); then
            USER_LAST_ACTIVITY_DATE="$KEY_LAST_USED_DATE"
            USER_LAST_ACTIVITY_DAYS_NUM="$KEY_LAST_USED_DAYS"
          fi
        fi
      fi

      SHOULD_NOTIFY="false"
      SHOULD_DISABLE="false"
      SHOULD_DELETE="false"
      REASONS=()

      if [[ -n "$INACTIVE_DAYS" ]]; then
        if (( INACTIVE_DAYS >= KEY_DELETE_DAYS )); then
          SHOULD_DELETE="true"
          REASONS+=("inactive_ge_${KEY_DELETE_DAYS}d")
        elif (( INACTIVE_DAYS >= KEY_DISABLE_DAYS )); then
          SHOULD_DISABLE="true"
          REASONS+=("inactive_ge_${KEY_DISABLE_DAYS}d")
        elif (( INACTIVE_DAYS >= KEY_NOTIFY_DAYS )); then
          SHOULD_NOTIFY="true"
          REASONS+=("inactive_ge_${KEY_NOTIFY_DAYS}d")
        fi
      fi

      if [[ "$KEY_STATUS" == "Active" ]]; then
        if [[ "$SHOULD_NOTIFY" == "true" ]]; then
          echo "$ACCESS_KEY_ID" >> keys_notify.list
        fi
        if [[ "$SHOULD_DISABLE" == "true" ]]; then
          echo "$ACCESS_KEY_ID" >> keys_disable.list
        fi
        if [[ "$SHOULD_DELETE" == "true" ]]; then
          echo "$ACCESS_KEY_ID" >> keys_delete.list
        fi
      fi

      KEY_JSON="$(jq -n \
        --arg account_id "$ACCOUNT_ID" \
        --arg user_name "$USER_NAME" \
        --arg user_path "$USER_PATH" \
        --arg user_create_date "$USER_CREATE_DATE" \
        --argjson user_age_days "${USER_AGE_DAYS:-0}" \
        --arg access_key_id "$ACCESS_KEY_ID" \
        --arg key_status "$KEY_STATUS" \
        --arg key_create_date "$KEY_CREATE_DATE" \
        --argjson key_age_days "${KEY_AGE_DAYS:-0}" \
        --arg key_last_used_date "${KEY_LAST_USED_DATE:-}" \
        --argjson key_last_used_days "${KEY_LAST_USED_DAYS:-0}" \
        --arg key_last_used_service "${KEY_LAST_USED_SERVICE:-}" \
        --arg key_last_used_region "${KEY_LAST_USED_REGION:-}" \
        --argjson inactivity_days "${INACTIVE_DAYS:-0}" \
        --arg notify "$SHOULD_NOTIFY" \
        --arg disable "$SHOULD_DISABLE" \
        --arg delete "$SHOULD_DELETE" \
        --arg reasons "$(printf '%s' "${REASONS[*]-}" | tr ' ' ',')" \
        --arg notify_email "${USER_NOTIFY_EMAIL:-}" \
        '{
          type: "key",
          account_id: $account_id,
          user_name: $user_name,
          user_path: $user_path,
          user_create_date: $user_create_date,
          user_age_days: $user_age_days,
          access_key_id: $access_key_id,
          key_status: $key_status,
          key_create_date: $key_create_date,
          key_age_days: $key_age_days,
          key_last_used_date: (if $key_last_used_date == "" then null else $key_last_used_date end),
          key_last_used_days: $key_last_used_days,
          key_last_used_service: (if $key_last_used_service == "" then null else $key_last_used_service end),
          key_last_used_region: (if $key_last_used_region == "" then null else $key_last_used_region end),
          inactivity_days: $inactivity_days,
          notify_email: (if $notify_email == "" then null else $notify_email end),
          flags: {
            notify: ($notify == "true"),
            disable: ($disable == "true"),
            delete: ($delete == "true")
          },
          reasons: (if $reasons == "" then [] else ($reasons | split(",")) end)
        }')"

      append_json "$KEY_JSON"
    done <<< "$KEYS_JSON"

    # ----- per-user inactivity (console password / overall) ------------------

    if [[ -n "$USER_PASSWORD_LAST_USED" ]]; then
      USER_LAST_ACTIVITY_DATE="$USER_PASSWORD_LAST_USED"
      USER_LAST_ACTIVITY_DAYS="$(days_since "$USER_PASSWORD_LAST_USED")"
    elif [[ "$USER_HAS_KEYS" == "true" && -n "$USER_LAST_ACTIVITY_DATE" ]]; then
      USER_LAST_ACTIVITY_DAYS="$USER_LAST_ACTIVITY_DAYS_NUM"
    else
      USER_LAST_ACTIVITY_DAYS="$USER_AGE_DAYS"
      USER_LAST_ACTIVITY_DATE=""
    fi

    USER_SHOULD_NOTIFY="false"
    USER_SHOULD_DISABLE="false"
    USER_SHOULD_DELETE="false"
    USER_REASONS=()

    if [[ -n "$USER_LAST_ACTIVITY_DAYS" ]]; then
      if (( USER_LAST_ACTIVITY_DAYS >= USER_DELETE_DAYS )); then
        USER_SHOULD_DELETE="true"
        USER_REASONS+=("inactive_ge_${USER_DELETE_DAYS}d")
      elif (( USER_LAST_ACTIVITY_DAYS >= USER_DISABLE_DAYS )); then
        USER_SHOULD_DISABLE="true"
        USER_REASONS+=("inactive_ge_${USER_DISABLE_DAYS}d")
      elif (( USER_LAST_ACTIVITY_DAYS >= USER_NOTIFY_DAYS )); then
        USER_SHOULD_NOTIFY="true"
        USER_REASONS+=("inactive_ge_${USER_NOTIFY_DAYS}d")
      fi
    fi

    if [[ "$USER_SHOULD_NOTIFY" == "true" ]]; then
      echo "$USER_NAME" >> users_notify.list
    fi
    if [[ "$USER_SHOULD_DISABLE" == "true" ]]; then
      echo "$USER_NAME" >> users_disable.list
    fi
    if [[ "$USER_SHOULD_DELETE" == "true" ]]; then
      echo "$USER_NAME" >> users_delete.list
    fi

    USER_JSON="$(jq -n \
      --arg account_id "$ACCOUNT_ID" \
      --arg user_name "$USER_NAME" \
      --arg user_path "$USER_PATH" \
      --arg user_create_date "$USER_CREATE_DATE" \
      --argjson user_age_days "${USER_AGE_DAYS:-0}" \
      --arg last_activity_date "${USER_LAST_ACTIVITY_DATE:-}" \
      --argjson last_activity_days "${USER_LAST_ACTIVITY_DAYS:-0}" \
      --arg notify "$USER_SHOULD_NOTIFY" \
      --arg disable "$USER_SHOULD_DISABLE" \
      --arg delete "$USER_SHOULD_DELETE" \
      --arg reasons "$(printf '%s' "${USER_REASONS[*]-}" | tr ' ' ',')" \
      --arg notify_email "${USER_NOTIFY_EMAIL:-}" \
      '{
        type: "user_summary",
        account_id: $account_id,
        user_name: $user_name,
        user_path: $user_path,
        user_create_date: $user_create_date,
        user_age_days: $user_age_days,
        user_last_activity_date: (if $last_activity_date == "" then null else $last_activity_date end),
        user_last_activity_days: $last_activity_days,
        notify_email: (if $notify_email == "" then null else $notify_email end),
        flags: {
          notify: ($notify == "true"),
          disable: ($disable == "true"),
          delete: ($delete == "true")
        },
        reasons: (if $reasons == "" then [] else ($reasons | split(",")) end)
      }')"

    append_json "$USER_JSON"

  done <<< "$USERS_JSON"
done

# Deduplicate lists
for f in keys_notify.list keys_disable.list keys_delete.list \
         users_notify.list users_disable.list users_delete.list; do
  if [[ -f "$f" ]]; then
    sort -u "$f" -o "$f"
  fi
done

if [[ -f .iam_hygiene_tmp.json ]]; then
  jq -s '.' .iam_hygiene_tmp.json > iam_hygiene.json
  rm -f .iam_hygiene_tmp.json
else
  echo "[]" > iam_hygiene.json
fi

# Disable/delete keys and users (skipped in DRY RUN)

echo "Applying lifecycle actions for account: ${ACCOUNT_ID}"

if [[ "$DRY_RUN" == "true" ]]; then
  echo ">>> DRY RUN: no IAM changes will be made"
else
  # Disable keys
  if jq -e '.[] | select(.type=="key" and .flags.disable==true)' iam_hygiene.json >/dev/null 2>&1; then
    jq -r '.[] | select(.type=="key" and .flags.disable==true) | "\(.user_name) \(.access_key_id)"' iam_hygiene.json | \
    while read -r u k; do
      echo "Disabling access key ${k} for user ${u}"
      aws iam update-access-key --user-name "$u" --access-key-id "$k" --status Inactive || \
        echo "WARNING: Failed to disable access key ${k} for user ${u}" >&2
    done
  fi

  # Delete keys
  if jq -e '.[] | select(.type=="key" and .flags.delete==true)' iam_hygiene.json >/dev/null 2>&1; then
    jq -r '.[] | select(.type=="key" and .flags.delete==true) | "\(.user_name) \(.access_key_id)"' iam_hygiene.json | \
    while read -r u k; do
      echo "Deleting access key ${k} for user ${u}"
      aws iam delete-access-key --user-name "$u" --access-key-id "$k" || \
        echo "WARNING: Failed to delete access key ${k} for user ${u}" >&2
    done
  fi

  # Disable users (console password)
  if jq -e '.[] | select(.type=="user_summary" and .flags.disable==true)' iam_hygiene.json >/dev/null 2>&1; then
    jq -r '.[] | select(.type=="user_summary" and .flags.disable==true) | .user_name' iam_hygiene.json | \
    while read -r u; do
      echo "Disabling console login for user ${u}"
      aws iam delete-login-profile --user-name "$u" 2>/dev/null || \
        echo "NOTE: No login profile to delete for user ${u}" >&2
    done
  fi

  # Delete users
  if jq -e '.[] | select(.type=="user_summary" and .flags.delete==true)' iam_hygiene.json >/dev/null 2>&1; then
    jq -r '.[] | select(.type=="user_summary" and .flags.delete==true) | .user_name' iam_hygiene.json | \
    while read -r u; do
      echo "Deleting IAM user ${u}"

      # Delete remaining access keys (if any)
      for key_id in $(aws iam list-access-keys --user-name "$u" --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null || echo ""); do
        [[ -z "$key_id" ]] && continue
        echo "  - deleting remaining key ${key_id}"
        aws iam delete-access-key --user-name "$u" --access-key-id "$key_id" || true
      done

      # Detach managed policies
      for arn in $(aws iam list-attached-user-policies --user-name "$u" --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null || echo ""); do
        [[ -z "$arn" ]] && continue
        echo "  - detaching policy ${arn}"
        aws iam detach-user-policy --user-name "$u" --policy-arn "$arn" || true
      done

      # Delete inline policies
      for pname in $(aws iam list-user-policies --user-name "$u" --query 'PolicyNames[]' --output text 2>/dev/null || echo ""); do
        [[ -z "$pname" ]] && continue
        echo "  - deleting inline policy ${pname}"
        aws iam delete-user-policy --user-name "$u" --policy-name "$pname" || true
      done

      # Remove from groups
      for g in $(aws iam list-groups-for-user --user-name "$u" --query 'Groups[].GroupName' --output text 2>/dev/null || echo ""); do
        [[ -z "$g" ]] && continue
        echo "  - removing from group ${g}"
        aws iam remove-user-from-group --user-name "$u" --group-name "$g" || true
      done

      # Delete login profile (if exists)
      aws iam delete-login-profile --user-name "$u" 2>/dev/null || true

      # Finally delete user
      if ! aws iam delete-user --user-name "$u"; then
        echo "WARNING: Failed to delete user ${u} – manual cleanup may be required" >&2
      fi
    done
  fi
fi

# Summary + per-user GOV.UK Notify emails (skipped in DRY RUN)

echo "--------------------------------------------"
echo "IAM hygiene actions complete for account: ${ACCOUNT_ID}"
[[ -f keys_notify.list   ]] && echo "  Keys to notify about : $(wc -l < keys_notify.list)"   || echo "  Keys to notify about : 0"
[[ -f keys_disable.list  ]] && echo "  Keys disabled        : $(wc -l < keys_disable.list)"  || echo "  Keys disabled        : 0"
[[ -f keys_delete.list   ]] && echo "  Keys deleted         : $(wc -l < keys_delete.list)"   || echo "  Keys deleted         : 0"
[[ -f users_notify.list  ]] && echo "  Users to notify      : $(wc -l < users_notify.list)"  || echo "  Users to notify      : 0"
[[ -f users_disable.list ]] && echo "  Users disabled       : $(wc -l < users_disable.list)" || echo "  Users disabled       : 0"
[[ -f users_delete.list  ]] && echo "  Users deleted        : $(wc -l < users_delete.list)"  || echo "  Users deleted        : 0"
echo "--------------------------------------------"

if [[ "$DRY_RUN" == "true" ]]; then
  echo ">>> DRY RUN: skipping GOV.UK Notify emails"
  exit 0
fi

if [[ -n "${GOV_UK_NOTIFY_API_KEY:-}" && -n "${TEMPLATE_ID:-}" ]]; then
  echo "Preparing per-user GOV.UK Notify emails using template ${TEMPLATE_ID}"

  python3 << 'EOF'
import json
import os
import sys

try:
    from notifications_python_client.notifications import NotificationsAPIClient
except ImportError:
    print("notifications-python-client not installed; skipping Notify emails", file=sys.stderr)
    sys.exit(0)

api_key = os.getenv("GOV_UK_NOTIFY_API_KEY")
template_id = os.getenv("TEMPLATE_ID")
expected_version = os.getenv("EXPECTED_TEMPLATE_VERSION", "").strip()
account_id = os.getenv("ACCOUNT_ID", "unknown")

if not api_key or not template_id:
    print("Notify not fully configured; skipping", file=sys.stderr)
    sys.exit(0)

client = NotificationsAPIClient(api_key)

# Validate template version if provided (warn-only)
if expected_version:
    try:
        t = client.get_template(template_id)
        actual = str(t.get("version"))
        if actual != expected_version:
            print(
                f"WARNING: Template version mismatch (expected {expected_version}, actual {actual}); continuing anyway",
                file=sys.stderr,
            )
    except Exception as e:
        print(f"WARNING: Failed to fetch template details: {e}; continuing anyway", file=sys.stderr)

try:
    with open("iam_hygiene.json") as f:
        data = json.load(f)
except Exception as e:
    print(f"ERROR: Failed to read iam_hygiene.json: {e}", file=sys.stderr)
    data = []

# Notify-stage users with an email from the tag
notify_users = [
    o for o in data
    if o.get("type") == "user_summary"
    and o.get("flags", {}).get("notify")
    and o.get("notify_email")
]

if not notify_users:
    print("No users to notify; skipping GOV.UK Notify emails", file=sys.stderr)
    sys.exit(0)

print(f"Found {len(notify_users)} user(s) to notify")

errors = 0
for u in notify_users:
    email = u.get("notify_email")
    username = u.get("user_name")
    last_days = u.get("user_last_activity_days")
    if not email:
        print(f"Skipping user {username}: no notify_email set", file=sys.stderr)
        continue
    try:
        client.send_email_notification(
            email_address=email,
            template_id=template_id,
            personalisation={
                # your template uses ((username)); extra fields are safe
                "username": username,
                "account_id": account_id,
                "inactive_days": last_days,
            },
        )
        print(f"Sent Notify email to {email} for user {username}")
    except Exception as e:
        errors += 1
        print(f"ERROR: Failed to send Notify email to {email} for user {username}: {e}", file=sys.stderr)

if errors:
    print(f"Completed Notify run with {errors} error(s)", file=sys.stderr)
else:
    print("All Notify emails sent successfully")

EOF

else
  echo "GOV.UK Notify not configured (GOV_UK_NOTIFY_API_KEY or TEMPLATE_ID missing); skipping emails"
fi

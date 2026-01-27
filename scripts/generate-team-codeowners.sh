codeowners_file=.github/CODEOWNERS
environment_json_dir=environments

generate_codeowners() {

  cat > "$codeowners_file" << EOL
# This file is auto-generated here, do not manually amend.
# https://github.com/ministryofjustice/modernisation-platform/blob/main/scripts/generate-team-codeowners.sh

* @ministryofjustice/modernisation-platform
EOL

  for file in "$environment_json_dir"/*.json; do
    application_name=$(basename "$file" .json)
    account_type=$(jq -r '."account-type"' "$file")

    if [ "$account_type" = "core" ]; then
      echo "Skipping core account: $application_name"
      continue
    fi

    directory="/terraform/environments/core-shared-services/${application_name}.tf"

    # Prefer codeowners if present
    if jq -e '.codeowners != null and (.codeowners | length > 0)' "$file" >/dev/null 2>&1; then
      codeowners=$(jq -r '(.codeowners | if type=="array" then . else [.] end)[] | select(length > 0) | "@ministryofjustice/" + .' "$file" | grep -v '^@ministryofjustice/azure-aws-sso' | sort -u | tr '\n' ' ')
      echo "Adding $directory $codeowners to CODEOWNERS"
      echo "$directory $codeowners" >> "$codeowners_file"
    else
      sso_group_names=$(jq -r '.environments[].access[].sso_group_name | "@ministryofjustice/" + .' "$file" | grep -v '^@ministryofjustice/azure-aws-sso' | sort -u | tr '\n' ' ')
      echo "Adding $directory $sso_group_names to CODEOWNERS"
      echo "$directory $sso_group_names" >> "$codeowners_file"
    fi
  done
}

generate_codeowners

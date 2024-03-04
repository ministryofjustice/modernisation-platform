#!/bin/bash

# Define array of files/directories changed in the PR
readarray -t CHANGED_DIRECTORIES <<< "$(gh pr view ${{ github.event.number }} --json files --jq '.files.[].path')"
printf %"s\n" "This PR is making changes to the following files/directories: "${CHANGED_DIRECTORIES[@]}""

# Define array of regexes for files/directories that require a warning
files=($(jq -r '.danger_files[].file' policies/pr-messages.json))

# Compare the arrays to see if there is a match and add a comment to a pr-comments.txt
for value1 in "${CHANGED_DIRECTORIES[@]}"; do
    for value2 in "${files[@]}"; do 
        if [[ "$value1" =~ $value2 ]]; then
            echo "${value1} matched ${value2}"
            echo -e ":warning: $(jq -r ".danger_files[] | select(.file == \"$value2\") | .message" policies/pr-messages.json) \n" >> pr-comments.txt
            echo "**Please check the plan carefully before deploying these changes.**" >> pr-comments.txt
        fi
    done
done

# If any matches are found then format the PR comment body and post it to the PR 
if [ -f pr-comments.txt ]; then
    cat pr-comments.txt | sort -u | sed G > pr-comment-body.txt
    gh pr comment ${{ github.event.number }} --body-file pr-comment-body.txt
fi
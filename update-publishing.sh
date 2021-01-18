#!/bin/sh

TEMPLATE_REPO=https://raw.githubusercontent.com/ministryofjustice/template-documentation-site/main
PUBLISH_YML=${TEMPLATE_REPO}/.github/workflows/publish.yml
MAKEFILE=${TEMPLATE_REPO}/makefile

# Remove local files which are now provided by the publishing docker image
echo "Removing files which are no longer needed."
rm Gemfile Gemfile.lock config.rb

# Replace the makefile
echo "Updating makefile"
curl -s ${MAKEFILE} > makefile

# Replace the publishing github action, preserving the ROOT_DOCPATH setting.
# This is a bit brittle, but hopefully any errors will be caught by a manual
# check.
echo "Updating .github/workflows/publish.yml"
grep ROOT_DOCPATH .github/workflows/publish.yml > root-docpath
curl -s ${PUBLISH_YML} | grep -v ROOT_DOCPATH > .github/workflows/publish.yml
cat root-docpath >> .github/workflows/publish.yml
rm root-docpath

echo
echo Update complete.
echo
echo Please check the changes, then "git add" and "git push"
echo

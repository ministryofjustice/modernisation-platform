#!/bin/bash

# Based on: https://github.com/ministryofjustice/opg-org-infra/blob/main/scripts/redact_output.sh

sed -e 's/AWS_SECRET_ACCESS_KEY".*/<REDACTED>/g' \
    -e 's/AWS_ACCESS_KEY_ID".*/<REDACTED>/g' \
    -e 's/$AWS_SECRET_ACCESS_KEY".*/<REDACTED>/g' \
    -e 's/$AWS_ACCESS_KEY_ID".*/<REDACTED>/g' \
    -e 's/\[id=.*\]/\[id=<REDACTED>\]/g'

#!/bin/bash

# Based on: https://github.com/ministryofjustice/opg-org-infra/blob/main/scripts/redact_output.sh

sed -u -e 's/AWS_SECRET_ACCESS_KEY".*/<REDACTED>/g' \
    -u -e 's/AWS_ACCESS_KEY_ID".*/<REDACTED>/g' \
    -u-e 's/$AWS_SECRET_ACCESS_KEY".*/<REDACTED>/g' \
    -u -e 's/$AWS_ACCESS_KEY_ID".*/<REDACTED>/g' \
    -u -e 's/\[id=.*\]/\[id=<REDACTED>\]/g' \
    -u -e 's/::[0-9]\{12\}:/::REDACTED:/g' \
    -u -e 's/:[0-9]\{12\}:/:REDACTED:/g'

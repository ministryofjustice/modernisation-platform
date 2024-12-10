#!/bin/bash

# Based on: https://github.com/ministryofjustice/opg-org-infra/blob/main/scripts/redact_output.sh

sed -u -E "s/AWS_SECRET_ACCESS_KEY=.*/AWS_SECRET_ACCESS_KEY=<REDACTED>/g" \
    -u -E "s/AWS_ACCESS_KEY_ID=.*/AWS_ACCESS_KEY_ID=<REDACTED>/g" \
    -u -E "s/\$(AWS_SECRET_ACCESS_KEY)=.*/\$(AWS_SECRET_ACCESS_KEY)=<REDACTED>/g" \
    -u -E "s/\$(AWS_ACCESS_KEY_ID)=.*/\$(AWS_ACCESS_KEY_ID)=<REDACTED>/g" \
    -u -E "s/\[id=[^]]*\]/\[id=<REDACTED>]/g" \
    -u -E "s/::[0-9]{12}:/::REDACTED:/g" \
    -u -E "s/:[0-9]{12}:/:REDACTED:/g"

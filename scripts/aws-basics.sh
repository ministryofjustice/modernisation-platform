#!/usr/bin/env bash

aws s3api head-object --bucket modernisation-platform-terraform-state --key "environments/accounts/bench/bench-development/terraform.tfstate" | jq .


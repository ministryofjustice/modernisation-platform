# Modernisation Platform Infrastructure

This directory contains the infrastructure as code to recreate and administer the Modernisation Platform.

## Contents

- [environments](environments) contains code to manage environments
- [modernisation-platform-account](modernisation-platform-account) contains code to manage the Modernisation Platform landing zone account
- [modules](modules) contains Terraform modules we've built and are testing
- [templates](templates) contains Terraform templates that are copied to each environment directory in `./environments`

## Terraform state backend

Terraform state is stored in the `modernisation-platform-terraform-state` S3 bucket.

Use [`../scripts/terraform-init.sh`](../scripts/terraform-init.sh) to initialise Terraform. The script passes the platform state bucket KMS key to the S3 backend so state and lock writes use customer-managed SSE-KMS.

For local testing, `TERRAFORM_STATE_KMS_KEY_ID` can be set to override the default key.

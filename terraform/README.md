# Modernisation Platform Infrastructure

This directory contains the infrastructure as code to recreate and administer the Modernisation Platform.

## Contents

- [environments](environments) contains code to create environments, and configure baselines within them, such as the Ministry of Justice [Security Guidance](https://ministryofjustice.github.io/security-guidance/baseline-aws-accounts/#baseline-for-amazon-web-services-accounts) baselines
- [github](github) contains code to create and configure our GitHub repositories and teams
- [modernisation-platform-account](modernisation-platform-account) contains code for resources that sit within the Modernisation Platform account, such as S3 bucket definitions for all our Terraform states; or Route53 definitions that can be used across accounts but sit within the Modernisation Platform account
- [templates](templates) contains template files for use with the [`templatefile()`](https://www.terraform.io/docs/configuration/functions/templatefile.html) function in Terraform

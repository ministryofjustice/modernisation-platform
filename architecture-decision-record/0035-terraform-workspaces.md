# 35. Use of Terraform Workspaces

Date: 2024-12-01

## Status

✅ Accepted

## Context

Terraform [workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) allow us to use code consistently across environments while maintain separation of state files.

## Decision

We will continue the use of workspaces for separation. Code which uses the `default` workspace will be documented here as an exception.

## Exceptions

* `terraform/modernisation-platform-account`
* `terraform/github`

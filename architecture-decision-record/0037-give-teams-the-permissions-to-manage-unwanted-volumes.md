# 37. Give Users the Permissions to Manage Unwanted EBS Volumes

Date: 2025-09-24

## Status

✅ Accepted

## Context

Currently, users must submit a request to the Modernisation Platform team to remove unwanted EBS volumes from their accounts.

In Issue #11343
, several approaches were considered:

- Granting users direct permissions to delete their own volumes, including limiting this just to non-production accounts.

- Providing tooling to process requests automatically, either in the form of a script or a workflow/lambda.

- Retaining the current model, where only Platform Admins hold the required permissions.

These options were reviewed at the Ways of Engineering meeting, and a decision was reached.

## Decision

Users will be given the ability to manage (list and delete) their own unwanted EBS volumes.

To implement this:

- A new SSO role and IAM policy will be created.

- The policy will grant only the minimum permissions required to list and delete volumes, ensuring it cannot be used as a general-purpose role.

- As with other SSO roles, access will be managed through association with a GitHub team defined in the environment.json file.

- An issue will be raised for the creation and testing of this new role & policy.
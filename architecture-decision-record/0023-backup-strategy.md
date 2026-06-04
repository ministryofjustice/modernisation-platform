# 23. Backup Strategy

Date: 2022-11-11

## Status

✅ Accepted

## Context

The Modernisation Platform hosts multiple production services. We need to ensure that these services are properly backed up, either by enabling users to back up things for themselves, or by providing a backup service.

## Decision

We will back up production instances (tagged as production) nightly using [AWS Backup](https://aws.amazon.com/backup/), this has already been implemented [here](https://github.com/ministryofjustice/modernisation-platform-terraform-baselines/tree/main/modules/backup), for all member accounts, using the secure baselines module.

We will create an AWS Backup plan to allow users to back up non production instances nightly by tagging their instance with a backup tag. The issue for this new feature is [here](https://github.com/ministryofjustice/modernisation-platform/issues/2612).

We will allow users to create their own custom backup plans for any eventualities not covered by the above. The issue for this new feature is [here](https://github.com/ministryofjustice/modernisation-platform/issues/2613)

We will opt in for all AWS Backup services as standard, this is already in place.

Any other custom backup needs, eg Oracle Dataguard etc will need to be provided and managed by the application team.

## Consequences

- [x] Create tickets for the above decisions

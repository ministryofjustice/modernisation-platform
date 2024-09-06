# 33.  Increase security of sensitive S3 objects (state bucket)

Date: 2024-09-06

## Status

❌ Rejected

## Context

While we can control access to objects in S3 such as terraform state files through bucket policies, we can risk accidental disclosure if bucket policies & IAM policies are not suitably strict.

Investigated [here](https://github.com/ministryofjustice/modernisation-platform/issues/5346).

It solves the ability for a user to move laterally across roles like so:

- User in Account B assumes Role X in Account A that has access to Object B
- User then assumes Role Y that has access to Object C
- Because the aws:PrincipalTag remains consistent as that of Account B, this will not match the value in the object tag and access to Object C will be denied

This has been rectified since the ticket was raised.

## Options

- Adding condition to policy [here](https://github.com/ministryofjustice/modernisation-platform/pull/7860/files)
- This requires changes to the state bucket tagging

### 1. Implement bucket policy checking principal account number when switching roles

#### Pros

- Adds a layer of security, stopping people from viewing other teams statefiles.

#### Cons

- Original secuirty reason for implementing has been fixed
- Requires changes to state buckets tagging
- Does not bring added security currently


## Decision

Since the ticket was raised, what was possible, and a possible risk has now been rectified. This means the work provides little to no value currently. The condition that is required for the bucket exists now, but changes to the bucket itself are required still.

## Consequences

- Modernisation Platform will not make changes to the state buckets tagging of resources.

# 8. Use KMS in the Shared Services Account for Cross Account Encryption

Date: 2021-06-17

## Status

✅ Accepted

## Context

Member account users will need to share encrypted things such as backups and snapshots between AWS accounts.

## Decision

We've decided to use [AWS Key Management Service (KMS)](https://aws.amazon.com/kms/) for cross account encryption.

Keys will be created per business unit as standard, if users require application level keys we will create these as and when needed.

## Consequences

### General consequences

* we will create KMS keys in the core-shared-services account
* keys will be created per business unit automatically upon business unit creation
* there will be an RDS, EBS, and General key per business unit
* key policy will only allow access to accounts with the relevant business unit

### Advantages

* easy for users
* users can share KMS encrypted things between their accounts
* we can control the management and rotation of keys
* per business unit is a good balance between security vs the number of keys to manage

### Disadvantages

* if users need application level keys we will need to do this manually

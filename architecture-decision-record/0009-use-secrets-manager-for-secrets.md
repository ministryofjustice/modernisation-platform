# 9. Use Secrets Manager for Secrets

Date: 2021-06-18

## Status

✅ Accepted

## Context

The Modernisation Platform team and its users need a way to store secrets securely. There are several different methods currently used across the MoJ, including [Secrets Manager](https://aws.amazon.com/secrets-manager/), [Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html), [LastPass](https://www.lastpass.com/) and [Git-Crypt](https://github.com/AGWA/git-crypt).

There are also other well known industry solutions such as [HashiCorp Vault](https://www.vaultproject.io/). We want to have a consistent solution across the Modernisation Platform.

## Decision

We've decided to use [Secrets Manager](https://aws.amazon.com/secrets-manager/) for our secrets storage.

Parameter store can be used to store non secret parameters if needed for environment specific configuration, but the first choice should be using an app_variables.json like [here](https://github.com/ministryofjustice/modernisation-platform-environments/blob/main/terraform/environments/sprinkler/app_variables.json)

## Consequences

### General consequences

* any secrets will be stored in Secrets Manager
* there will be no sharing of secrets across accounts
* secret rotation via Secrets Manager should be used where possible
* SSO permission sets will be updated to allow users to manage their secrets

### Advantages

* compatible with AWS services
* automated secret rotation possible
* users manage their own secrets

### Disadvantages

* Secrets Manager is more expensive than Parameter Store

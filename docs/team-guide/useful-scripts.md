## Useful scripts

In the Modernisation Platform repository, we have some [useful scripts](https://github.com/ministryofjustice/modernisation-platform/tree/main/scripts) for common things for working on the Modernisation Platform.

### [`check-environment-definitions.js`](https://github.com/ministryofjustice/modernisation-platform/tree/main/scripts/check-environment-definitions.js)

Used as part of a CI/CD pipeline? ✅

This script is run via the [check-environment-definitions.yml workflow](https://github.com/ministryofjustice/modernisation-platform/blob/main/.github/workflows/check-environment-definitions.yml) when a JSON file is added or changes in the `/environments` directory and a PR is subsequently created. It checks that the JSON file includes required tags and comments on the PR if there's an issue.

### [`create-accounts.sh`](https://github.com/ministryofjustice/modernisation-platform/tree/main/scripts/create-accounts.sh)

Used as part of a CI/CD pipeline? ✅

This script is run via the [create-accounts.yml workflow](https://github.com/ministryofjustice/modernisation-platform/blob/main/.github/workflows/create-accounts.yml) when a PR is merged into `main` that has a new environment definition. It runs the Terraform to create the environment.


### [`create-per-account-local-workspaces.sh`](https://github.com/ministryofjustice/modernisation-platform/tree/main/scripts/create-per-account-local-workspaces.sh)

Used as part of a CI/CD pipeline? ❌

This can be run to create a local environment directories and their subsequent Terraform workspaces.

### `utilities.js`

Used as part of a CI/CD pipeline? ✅

Used as part of `check-environment-definitions.js`.

### `internal/loop-through-bootstrap-workspaces-and-plan.sh`

Used as part of a CI/CD pipeline? ❌

This script shouldn't be run as part of a CI/CD pipeline as it may leak secrets. It can be run locally to check each account has been correctly bootstrapped, or to see what is going to be created across all environments if you add a new resource to the bootstrap file. It is in the `internal` subdirectory to separate it from publicly runnable scripts.

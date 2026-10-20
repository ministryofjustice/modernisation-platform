# Open Policy Agent

We use [Conftest](https://www.conftest.dev/) and [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) to test json files and policies.

## Setup
[Install Conftest](https://www.conftest.dev/install/)

## Run the tests

This runs the OPA tests against each json file in the [environments](../environments) and [environments-networks](../environments-networks) folder against the relevant policy folder.

The policies in the [member](./member) folder are additional policies that will only run against an environments .JSON file if the `account-type` is `member`. This is because some of the early core and unrestricted accounts do not follow are current naming conventions.

[scripts/tests/validate/run-opa-tests.sh](../scripts/tests/validate/run-opa-tests.sh)

## Run the test unit tests

These verify that the tests are running as expected.

`conftest verify -p policies/environments`

`conftest verify -p policies/networking`

`conftest verify -p policies/member`
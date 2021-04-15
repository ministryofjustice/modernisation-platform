# Open Policy Agent

We use [Conftest](https://www.conftest.dev/) and [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) to test json files and policies.

## Setup
[Install Conftest](https://www.conftest.dev/install/)

## Run the tests

This runs the OPA tests against each json file in the [environments](../environments) and [environments-networks](../environments-networks) folder against the relevant policy folder.

[scripts/tests/validate/opa.sh](../scripts/tests/validate/opa.sh)

## Run the test unit tests

These verify that the tests are running as expected.

`conftest verify -p policies/environments`

`conftest verify -p policies/networking`

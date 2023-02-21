# 7. Use Terratest, Open Policy Agent and Go for testing

Date: 2021-04-15

## Status

✅ Accepted

## Context

In the Modernisation Platform, we want to have confidence that we can make changes without breaking things.

## Decision

We've decided to use the following tools for testing:

* [Terratest](https://terratest.gruntwork.io/) for infrastructure testing
  * with [localstack](https://github.com/localstack/localstack) where possible
  * in a suitable account if not
* [Open Policy Agent](https://www.openpolicyagent.org/) for JSON and policy tesing
  * with [conftest](https://www.conftest.dev/)
* [Go testing framework](https://golang.org/pkg/testing/) for anything else
* We will run tests on pipelines where possible

## Consequences

### General consequences

We believe we can cover most of our testing needs with these tools. We recognise that we want smoke tests as well, but will look into these at a later date.

### Advantages

* These tools are open source and well established.
* By using Go we have a consistent language across testing (Terratest is a Go library).
* OPA can also be used to test Terraform infrastructure that we cannot easily create and destroy (such as accounts or certificate authorities) by testing the Teraform plan.
* Cloud Platform are using or evaluating the same tools, so we will be aligned with them.

### Disadvantages

* Go is not one of our core languages.
* We don't know yet if these tools can be used for smoke tests.

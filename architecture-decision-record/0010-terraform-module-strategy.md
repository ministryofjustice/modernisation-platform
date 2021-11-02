# 10. Terraform Module Strategy

Date: 2021-06-18

## Status

✅ Accepted

## Context

The Modernisation Platform uses [Terraform](https://www.terraform.io/) for its infrastructure as code. To make infrastructure reusable, or to simply tidy up code you can use [Terraform Modules](https://www.terraform.io/docs/language/modules/). There are different use cases in the platform for using modules, and this ADR outlines how we plan to use them.

## Decision

Modules used only by the Modernisation Platform core infrastructure will remain in the [terraform/modules](https://github.com/ministryofjustice/modernisation-platform/tree/main/terraform/modules) folder where they are currently located. These modules are mainly single use modules but created to keep the code tidier and easier to maintain. Modules used only by the core which currently have their own repository will remain where they are.

Modules used by users will have their own repository per module which we link to from the main repo. These modules will be versioned with GitHub releases, and tested with [Terratest](https://terratest.gruntwork.io/) against a test AWS account.

## Consequences

### General consequences

* new user modules will be created in their own repository
* a new template for module repositories should be created for consistency, similar to [Cloud Platform Module Template](https://github.com/ministryofjustice/cloud-platform-terraform-template)
* we will name modules using the format `modernisation-platform-terraform-module-name`
* core platform modules can stay where they are currently located
* modules should be tested with Terratest
* we will need to create a testing environment for Terratest to run

### Advantages

* we can version user modules with GitHub releases to avoid breaking existing infrastructure when updating modules
* testing gives us confidence
* keeping our core modules together makes it easier for us to navigate the platform code
* we don't need to re-version core modules whenever we make a change to them

### Disadvantages

* user modules are scattered in various repositories (we will signpost them from the main repo to make it easier to find them)

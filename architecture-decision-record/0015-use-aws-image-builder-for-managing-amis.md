# 15. Use AWS image builder for managing AMIs

Date: 2021-11-02

## Status

✅ Accepted

## Context

There is likely to  be a common requirement across Modernisation Platform consumers to utilise the benefits of using customised AMIs, such as managed consistency of configuration and speed of EC2 instance deployment.

Some options to tackle AMI generation and management were considered
* A custom approach - based on a reference architecture (see <https://aws.amazon.com/blogs/awsmarketplace/announcing-the-golden-ami-pipeline/>) that brings together a number of tools and techniques to manage AMIs through their lifecycle. This approach brings with it a fair amount of complexity and arguably extra operational overhead.
* [Packer](https://www.packer.io/) - a common approach across private and public cloud platforms, using this Hashicorp tool to programmatically build AMIs. Such a solution would also need to manage the distribution of AMIs across accounts and lifecycle management of AMIs
* [AWS Image Builder](https://docs.aws.amazon.com/imagebuilder/latest/userguide/what-is-image-builder.html) - a managed AWS service incorporating concepts such as pipelines, recipes and components, and even a marketplace of build and test components. Image builder is based on the use of AWS Systems Manager (so no ssh connections and exposed ports). A solution based on this (at the time of writing) would need to also handle the lifecycle management of AMIs (as it the case with Packer)

## Decision

We will create an AMI generation and management capability based on AWS Image Builder.

## Consequences

- In order to achieve consistency, standardisation and maximisation of reuse, this capability would become the standard for building and managing AMIs across the Modernisation Platform consumers
- As the capability is being developed, feedback will be sought to ensure quality and relevancy to use cases
- A specific repository will be created to hold the Image Builder code and workflows for each team, with the ability for each team to autonomously manage the definition, production and distribution of their AMIs

### General consequences

* Teams will need to use AWS image builder (and code and workflows in an Image Builder Github repository) to manage their AMIs
* Design decisions will need to be take to identify optimal ways to manage and invoke Image Builder, with dependent infrastructure in the code-shared-services account, particularly from an infrastructure-as-code point-of-view
* The Modernisation Platform team will actively seek feedback to ensure early identification of challenges, blockers, improvements etc.

### Advantages

* An AWS managed service with [strong integration with related services](https://docs.aws.amazon.com/imagebuilder/latest/userguide/ibhow-integrations.html) such as KMS for EBS encryption, S3 for logging, CloudWatch for monitoring
* Some helpful abstraction of details with concepts such as pipelines, recipes and components (e.g. automatic triggering of pipelines when parent AMIs are updated)
* A useful repository of components that offer value for building and testing AMIs, e.g. security hardening components, AWS Inspector test components

### Disadvantages

* Supportability for older operating systems that don't support the AWS Systems Manager agent
* Image Builder's requirement for versioning of recipes and components doesn't sit nicely with Terraform's declarative approach. An approach to this will need to be explored and advertised
* Image building execution time is likely to be slower than Packer
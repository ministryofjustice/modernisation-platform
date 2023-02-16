# Ministry of Justice Modernisation Platform

[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=for-the-badge&logo=github&label=MoJ%20Compliant&query=%24.result&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fmodernisation-platform)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html#modernisation-platform "Link to report")

## About this repository

This is the Ministry of Justice [Modernisation Platform team](https://github.com/orgs/ministryofjustice/teams/modernisation-platform)'s repository for core work on the Modernisation Platform. The Modernisation Platform team is a [platform engineering product team](https://www.thoughtworks.com/radar/techniques/platform-engineering-product-teams) which provides a hosting platform for Ministry of Justice applications which cannot be hosted on the [Cloud Platform](https://user-guide.cloud-platform.service.justice.gov.uk/#cloud-platform-user-guide).

For more information on the Modernisation Platform please see the [user guidance](https://user-guide.modernisation-platform.service.justice.gov.uk).

## Contents

This repository currently holds the Modernisation Platform's:

- [Architecture Decision Record (ADR)](architecture-decision-record)
- [Environment definitions](environments)
- [Infrastructure as code](terraform)
- [Source code for user-guide.modernisation-platform.service.justice.gov.uk](source)

## Other useful repositories

### Core repositories

| Name                                                                                                                                      | Description                                                                         |
| ----------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| [Modernisation Platform](https://github.com/ministryofjustice/modernisation-platform) (this one)                                          | Our repository for core work, including our ADR and infrastructure as code          |
| [Modernisation Platform Environments](https://github.com/ministryofjustice/modernisation-platform-environments)                           | The repository for user application infrastructure as code and deployment workflows |
| [modernisation-platform-ami-builds](https://github.com/ministryofjustice/modernisation-platform-ami-builds)                               | Repository for creating pipelines to build AMIs for use on the platform             |
| [modernisation-platform-configuration-management](https://github.com/ministryofjustice/modernisation-platform-configuration-management)   | Repository for configuration management code used on the platform                   |
| [modernisation-platform-terraform-module-template](https://github.com/ministryofjustice/modernisation-platform-terraform-module-template) | Template repository used for creating other Terraform module repositories           |

### Terraform modules - for member account use

Modernisation Platform users can use these modules in their infrastructure. They are designed to comply with best practices and to work with the platform, to make creating infrastructure quicker, easier and more secure.

| Name                                                                                                                                                            | Description                                                                                                                                                     |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [modernisation-platform-terraform-bastion-linux](https://github.com/ministryofjustice/modernisation-platform-terraform-bastion-linux)                           | Module for creating Linux bastion servers in member AWS accounts                                                                                                |
| [modernisation-platform-terraform-ecs](https://github.com/ministryofjustice/modernisation-platform-terraform-ecs)                                               | Module for creating ECS cluster (Linux/Windows) solely for EC2 launch type                                                                                      |
| [modernisation-platform-terraform-s3-bucket](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket)                                   | Module for creating S3 buckets with sensible defaults e.g. replication, encryption                                                                              |
| [modernisation-platform-terraform-s3-bucket-replication-role](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket-replication-role) | Module for creating an IAM role for S3 bucket replication                                                                                                       |
| [modernisation-platform-terraform-aws-vm-import](https://github.com/ministryofjustice/modernisation-platform-terraform-aws-vm-import)                           | Module that creates s3 and roles needed to import virtual machine (VM) images from your virtualization environment to Amazon EC2 as Amazon Machine Images (AMI) |
| [modernisation-platform-terraform-pagerduty-integration](https://github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration)           | Module associating an SNS topic with a PagerDuty service                                                                                                        |
| [modernisation-platform-terraform-loadbalancer](https://github.com/ministryofjustice/modernisation-platform-terraform-loadbalancer)                             | Module that creates application loadbalancer in AWS with logging enabled, s3 to store logs and Athena DB to query logs                                          |
| [modernisation-platform-terraform-ssm-patching](https://github.com/ministryofjustice/modernisation-platform-terraform-ssm-patching)                             | Module that automates the patching of ec2 instances via ssm. It creates an s3 bucket for log storage, as well as maintnance windows, tasks, resource groups, and patch baselines.


### Terraform modules - used by the core platform

These modules are used by the Modernisation Platform's core infrastructure

| Name                                                                                                                                                              | Description                                                                                          |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| [modernisation-platform-terraform-baselines](https://github.com/ministryofjustice/modernisation-platform-terraform-baselines)                                     | Module for enabling and configuring common baseline services such as SecurityHub                     |
| [modernisation-platform-terraform-cross-account-access](https://github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access)               | Module for creating an IAM role that can be assumed from another account                             |
| [modernisation-platform-terraform-environments](https://github.com/ministryofjustice/modernisation-platform-terraform-environments)                               | Module for creating organizational units and accounts within AWS Organizations from JSON files       |
| [modernisation-platform-terraform-iam-superadmins](https://github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins)                         | Module for creating defined IAM users as superadmins                                                 |
| [modernisation-platform-terraform-trusted-advisor](https://github.com/ministryofjustice/modernisation-platform-terraform-trusted-advisor)                         | Module for refreshing Trusted Advisor every 60 minutes                                               |
| [modernisation-platform-terraform-member-vpc](https://github.com/ministryofjustice/modernisation-platform-terraform-member-vpc)                                   | Module for member VPC accounts                                                                       |
| [modernisation-platform-github-oidc-provider](https://github.com/ministryofjustice/modernisation-platform-github-oidc-provider)                                   | Module for creating OIDC providers to use in GitHub Actions                                          |

### Tools

| Name                                                                                                                          | Description                                          |
| ----------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| [modernisation-platform-instance-scheduler](https://github.com/ministryofjustice/modernisation-platform-instance-scheduler)   | A Go lambda function for stopping and starting instance, rds resources and autoscaling groups. The lambda is used by the core platform and can be reused outside of the platform with minimal changes |
| [modernisation-platform-infrastructure-test](https://github.com/ministryofjustice/modernisation-platform-infrastructure-test) | Infrastructure test tool based on Cucumber.js        |
| [modernisation-platform-cp-network-test](https://github.com/ministryofjustice/modernisation-platform-cp-network-test)         | Container bundled with utilities for network testing |

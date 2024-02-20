# Ministry of Justice Modernisation Platform

[![Standards Icon]][Standards Link]

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
| [modernisation-platform-terraform-ecs-cluster](https://github.com/ministryofjustice/modernisation-platform-terraform-ecs-cluster)                                               | Module for creating ECS cluster |
| [modernisation-platform-terraform-s3-bucket](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket)                                   | Module for creating S3 buckets with sensible defaults e.g. replication, encryption                                                                              |
| [modernisation-platform-terraform-s3-bucket-replication-role](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket-replication-role) | Module for creating an IAM role for S3 bucket replication                                                                                                       |
| [modernisation-platform-terraform-aws-vm-import](https://github.com/ministryofjustice/modernisation-platform-terraform-aws-vm-import)                           | Module that creates s3 and roles needed to import virtual machine (VM) images from your virtualization environment to Amazon EC2 as Amazon Machine Images (AMI) |
| [modernisation-platform-terraform-pagerduty-integration](https://github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration)           | Module associating an SNS topic with a PagerDuty service                                                                                                        |
| [modernisation-platform-terraform-loadbalancer](https://github.com/ministryofjustice/modernisation-platform-terraform-loadbalancer)                             | Module that creates application load balancer in AWS with logging enabled, s3 to store logs and Athena DB to query logs                                          |
| [modernisation-platform-terraform-ssm-patching](https://github.com/ministryofjustice/modernisation-platform-terraform-ssm-patching)                             | Module that automates the patching of ec2 instances via ssm. It creates an s3 bucket for log storage, as well as maintenance windows, tasks, resource groups, and patch baselines.
| [modernisation-platform-terraform-ec2-instance](https://github.com/ministryofjustice/modernisation-platform-terraform-ec2-instance)         | Module for creating an EC2 instance |
| [modernisation-platform-terraform-ec2-autoscaling-group](https://github.com/ministryofjustice/modernisation-platform-terraform-ec2-autoscaling-group)         | Module for creating an EC2 autoscaling group |
| [modernisation-platform-terraform-lambda-function](https://github.com/ministryofjustice/modernisation-platform-terraform-lambda-function)         | Module for creating a Lambda Function |

### Terraform modules - used by the core platform

These modules are used by the Modernisation Platform's core infrastructure

| Name                                                                                                                                                              | Description                                                                                          |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| [modernisation-platform-terraform-baselines](https://github.com/ministryofjustice/modernisation-platform-terraform-baselines)                                     | Module for enabling and configuring common baseline services such as SecurityHub                     |
| [modernisation-platform-terraform-cross-account-access](https://github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access)               | Module for creating an IAM role that can be assumed from another account                             |
| [modernisation-platform-terraform-environments](https://github.com/ministryofjustice/modernisation-platform-terraform-environments)                               | Module for creating organizational units and accounts within AWS Organizations from JSON files       |
| [modernisation-platform-terraform-iam-superadmins](https://github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins)                         | Module for creating defined IAM users as superadmins                                                 |                                        |
| [modernisation-platform-terraform-member-vpc](https://github.com/ministryofjustice/modernisation-platform-terraform-member-vpc)                                   | Module for member VPC accounts                                                                       |
| [modernisation-platform-github-oidc-provider](https://github.com/ministryofjustice/modernisation-platform-github-oidc-provider)                                   | Module for creating OIDC providers to use in GitHub Actions                                          |                                     |

### Tools

| Name                                                                                                                          | Description                                          |
| ----------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| [modernisation-platform-instance-scheduler](https://github.com/ministryofjustice/modernisation-platform-instance-scheduler)   | A Go lambda function for stopping and starting instance, rds resources and autoscaling groups. The lambda is used by the core platform and can be reused outside of the platform with minimal changes |
| [modernisation-platform-infrastructure-test](https://github.com/ministryofjustice/modernisation-platform-infrastructure-test) | Infrastructure test tool based on Cucumber.js        |
| [modernisation-platform-cp-network-test](https://github.com/ministryofjustice/modernisation-platform-cp-network-test)         | Container bundled with utilities for network testing |


[Standards Link]: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-report/modernisation-platform 'Repo standards badge.'

[Standards Icon]: https://img.shields.io/endpoint?labelColor=231f20&color=005ea5&style=for-the-badge&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fendpoint%2Fmodernisation-platform&logo=data:image/png;base64,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

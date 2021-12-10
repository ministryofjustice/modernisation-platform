# Ministry of Justice Modernisation Platform

## About this repository
This is the Ministry of Justice [Modernisation Platform team](https://github.com/orgs/ministryofjustice/teams/modernisation-platform)'s repository for core work on the Modernisation Platform. The Modernisation Platform team is a [platform engineering product team](https://www.thoughtworks.com/radar/techniques/platform-engineering-product-teams) which provides a hosting platform for Ministry of Justice applications which cannot be hosted on the [Cloud Platform](https://user-guide.cloud-platform.service.justice.gov.uk/#cloud-platform-user-guide).

For more information on the Modernisation Platform please see the [user guidance](https://user-guide.modernisation-platform.service.justice.gov.uk).

## Modernisation Platform's advantages and trade-offs

**Advantages**

Out of the box functionality

- GitOps
- Static Code Analysis with suggestions for best practices
- Dev/prod parity: https://12factor.net/dev-prod-parity
- Infrastructure is easier to reproduce and replicate
- Terraform modules with reasonable defaults tailored to maximise security and minimise costs

Increased security

- Deployments only through CI/CD, no direct deployments
- Environment isolation, dev cannot access prod and vice versa
- Each role has only the bare minimal access
- Deny all access that is not explicitly allowed

Flexibility: suitable for any kind of workloads

- Cloud-native or not
- Containerised or not
- Legacy or greenfield

**Trade-offs**

- The platform has a reasonable **learning curve** to comply with best practices: [user guidance](https://user-guide.modernisation-platform.service.justice.gov.uk/#modernisation-platform)
- The platform is focused on **production workloads**. For example, if you need a sandbox to quickly experiment with changes, the platform might get in your way because you will need to comply with best practices that might not be relevant to your imminent goal.
- The platform is **relatively new** and not yet thoroughly tested. First prod environment (Performance Hub) was deployed on 17 Nov 2021.

## Contents
This repository currently holds the Modernisation Platform's:
- [Architecture Decision Record (ADR)](architecture-decision-record)
- [Environment definitions](environments)
- [Infrastructure as code](terraform)
- [Source code for user-guide.modernisation-platform.service.justice.gov.uk](source)

## Other useful repositories
### Core repositories
| Name | Description |
|-|-|
| [Modernisation Platform](https://github.com/ministryofjustice/modernisation-platform) (this one) | Our repository for core work, including our ADR and infrastructure as code |
| [Modernisation Platform Environments](https://github.com/ministryofjustice/modernisation-platform-environments) | The repository for user application infrastructure as code and deployment workflows |

### Terraform modules - for member account use

Modernisation Platform users can use these modules in their infrastructure. They are designed to comply with best practices and to work with the platform, to make creating infrastructure quicker, easier and more secure.

| Name | Description |
|-|-|
| [modernisation-platform-terraform-bastion-linux](https://github.com/ministryofjustice/modernisation-platform-terraform-bastion-linux) | Module for creating Linux bastion servers in member AWS accounts |
| [modernisation-platform-terraform-ecs](https://github.com/ministryofjustice/modernisation-platform-terraform-ecs) | Module for creating ECS cluster (Linux/Windows) solely for EC2 launch type |
| [modernisation-platform-terraform-s3-bucket](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket) | Module for creating S3 buckets with sensible defaults e.g. replication, encryption |
| [modernisation-platform-terraform-s3-bucket-replication-role](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket-replication-role) | Module for creating an IAM role for S3 bucket replication |
| [modernisation-platform-terraform-aws-vm-import](https://github.com/ministryofjustice/modernisation-platform-terraform-aws-vm-import) | Module that creates s3 and roles needed to import virtual machine (VM) images from your virtualization environment to Amazon EC2 as Amazon Machine Images (AMI)   |
| [modernisation-platform-terraform-lambda-scheduler-stop-start](https://github.com/ministryofjustice/modernisation-platform-terraform-lambda-scheduler-stop-start) | Module for stopping and starting instance, rds resources and autoscaling groups with lambda function |

### Terraform modules - used core platform

These modules are used by the Modernisation Platform's core infrastructure

| Name | Description |
|-|-|
| [modernisation-platform-terraform-baselines](https://github.com/ministryofjustice/modernisation-platform-terraform-baselines) | Module for enabling and configuring common baseline services such as SecurityHub |
| [modernisation-platform-terraform-cross-account-access](https://github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access) | Module for creating an IAM role that can be assumed from another account |
| [modernisation-platform-terraform-environments](https://github.com/ministryofjustice/modernisation-platform-terraform-environments) | Module for creating organizational units and accounts within AWS Organizations from JSON files |
| [modernisation-platform-terraform-iam-superadmins](https://github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins) | Module for creating defined IAM users as superadmins |
| [modernisation-platform-terraform-trusted-advisor](https://github.com/ministryofjustice/modernisation-platform-terraform-trusted-advisor) | Module for refreshing Trusted Advisor every 60 minutes |

### Tools

| Name | Description |
|-|-|
| [modernisation-platform-infrastructure-test](https://github.com/ministryofjustice/modernisation-platform-infrastructure-test) | Infrastructure test tool based on Cucumber.js |

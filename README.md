# Ministry of Justice Modernisation Platform

## About this repository
This is the Ministry of Justice [Modernisation Platform team](https://github.com/orgs/ministryofjustice/teams/modernisation-platform)'s repository for core work on the Modernisation Platform.

## Contents
This repository currently holds the Modernisation Platform's:
- [Architecture Decision Record (ADR)](architecture-decision-record)
- [Environment definitions](environments)
- [Infrastructure as code](terraform)
- [Source code for ministryofjustice.github.io/modernisation-platform](docs)

## Other useful repositories
### Core repositories
| Name | Description |
|-|-|
| [Modernisation Platform](https://github.com/ministryofjustice/modernisation-platform) (this one) | Our repository for core work, including our ADR and infrastructure as code |

### Terraform modules
| Name | Description |
|-|-|
| [modernisation-platform-terraform-baselines](https://github.com/ministryofjustice/modernisation-platform-terraform-baselines) | Module for enabling and configuring common baseline services such as SecurityHub |
| [modernisation-platform-terraform-cross-account-access](https://github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access) | Module for creating an IAM role that can be assumed from another account |
| [modernisation-platform-terraform-environments](https://github.com/ministryofjustice/modernisation-platform-terraform-environments) | Module for creating organizational units and accounts within AWS Organizations from JSON files |
| [modernisation-platform-terraform-iam-superadmins](https://github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins) | Module for creating defined IAM users as superadmins |
| [modernisation-platform-terraform-s3-bucket-replication-role](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket-replication-role) | Module for creating an IAM role for S3 bucket replication |
| [modernisation-platform-terraform-s3-bucket](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket) | Module for creating S3 buckets with sensible defaults e.g. replication, encryption |
| [modernisation-platform-terraform-trusted-advisor](https://github.com/ministryofjustice/modernisation-platform-terraform-trusted-advisor) | Module for refreshing Trusted Advisor every 60 minutes |

# Ministry of Justice Modernisation Platform

## About this repository
This is the Ministry of Justice [Modernisation Platform team](https://github.com/orgs/ministryofjustice/teams/modernisation-platform)'s repository for public work on the Modernisation Platform.

## Contents
This repository currently holds the Modernisation Platform's:
- [Architecture Decision Record (ADR)](architecture-decision-record)
- [Infrastructure as code](terraform)
- [Environment definitions](environments)

## Other useful repositories
### Core repositories
| Name                   | Description                                                                  | Link                                                        |
|------------------------|------------------------------------------------------------------------------|-------------------------------------------------------------|
| Modernisation Platform | Our repository for public work, including our ADR and infrastructure as code | https://github.com/ministryofjustice/modernisation-platform |

### Terraform modules
| Name                                                  | Description                                                      | Link                                                                                       |
|-------------------------------------------------------|------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| modernisation-platform-terraform-environments         | Module for creating environment OUs and application accounts     | https://github.com/ministryofjustice/modernisation-platform-terraform-environments         |
| modernisation-platform-terraform-iam-federated-access | Module for configuring IAM Federated Access for AWS              | https://github.com/ministryofjustice/modernisation-platform-terraform-iam-federated-access |
| modernisation-platform-terraform-iam-superadmins      | Module for creating high-level set superadmins in an AWS account | https://github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins      |

# 14. Create Application Elastic Container Repositories (ECR) in the shared-services account

Date: 2021-09-27

## Status

✅ Accepted

## Context

Applications using Docker will sometimes need an ECR repo to store their Docker images.  Since we use a separate AWS account for each application environment, this will need to be in a shared location.

Some options which were considered:

* ECR repository per application in the shared services account
* Use a service provided by Operations Engineering (there is only Docker Hub currently)
* Use a hosted service such as Docker Hub
* ECR repository per application in one of the applications accounts which is then cross shared to other accounts

## Decision

We will create application ECR repositories in the shared-services account, and share them to the relevant accounts and account deployment CICD users.

For the moment we will create repositories on behalf of teams as and when they need them [here](https://github.com/ministryofjustice/modernisation-platform/blob/main/terraform/environments/core-shared-services/ecr_repos.tf) using the ECR module.

## Consequences

### General consequences

* teams will need to request the Modernisation Platform team to create a repository
* we may want to automate the creation per team at a later date if the management becomes too much
* teams can still use Docker Hub to host images if they wish

### Advantages

* simple solution to create a shared repository
* private repository with low costs
* full control over who can access the images

### Disadvantages

* overhead to add each repository to Terraform

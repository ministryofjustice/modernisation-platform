# 27. Use Member CICD Access for Configuration Management

Date: 2023-08-17

## Status

✅ Accepted

## Context

Users of the Modernisation Platform often host applications which require additional configuration on top of standard infrastructure provisioning.

This configuration whilst sometimes manual often can be achieved via code, eg scripts or running a configuration management tool such as Ansible on the server.

## Options

### 1. Run configuration management tools manually on servers

**Pros**

- Works
- Access already in place

**Cons**

- Not best practice
- Risk of things not being applied consistently
- Risk of errors

### 2. Run configuration management from the environments repository pipeline

**Pros**

- Automated solution
- Everything in one place

**Cons**

- Mixes infrastructure with configuration
- Environments repository is already very large

### 3. Run configuration management with another platform managed repository

**Pros**

- Automated solution
- Keeps infrastructure and configuration separate

**Cons**

- Hard to create something which works with different configuration management tools
- Different applications have different requirements, with infrastructure it is simpler as it uses one tool - Terraform.  One application may required Ansible, another may need to make calls to an AWS API
- Adds considerable overhead to the Modernisation Platform team

### 4. Applications run configuration management using their own pipelines and tooling, MP provides access

**Pros**

- Flexibility for application teams to run configuration management however they want to
- CICD access already present
- Infrastructure and configuration management separate

**Cons**

- More work for application teams

## Decision

Option 4. Applications will run configuration management using their own pipelines (not MP provided), accessing their accounts using the CICD access provided (currently the member-cicd user but soon to be changed to OIDC).

## Consequences

- Application teams will need to build their own configuration management pipelines in the tools of their choice.
- Configuration management code can still be stored in the [modernisation-platform-configuration-management](https://github.com/ministryofjustice/modernisation-platform-configuration-management) repository and pulled from there if teams need a central location to store and reuse code.
- Modernisation Platform team may need to increase the permissions provided to the CICD access, this should be done as and when requested and discussed in the team to ensure permissions are appropriate.

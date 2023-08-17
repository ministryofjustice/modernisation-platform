# 27. Use Member CICD Access for Configuration Management

Date: 2023-08-17

## Status

✅ Accepted

## Context

Users of the Modernisation Platform often host applications which require additional configuration on top of standard infrastructure provisioning.

This configuration whilst sometimes manual often can be achieved via code, eg scripts or running a configuration management tool such as Ansible on the server.

## Options

#### Run configuration management tools manually on servers

This works but is not best practice and runs the risk of things not being applied consistently.

#### Run configuration management from the environments repository pipeline

Automated solution and keeps everything in one place, but begins to mix infrastructure with configuration which we do not want to do. The environments repository is already very large and this will add to this.

#### Run configuration management with another platform managed repository

Automated solution and keeps infrastructure and configuration separate, however this will be hard to create something which works with different configuration management tools.  Different applications have different requirements, with infrastructure it is simpler as it uses one tool - Terraform.  One application may required Ansible, another may need to make calls to an AWS API.  This solution will add considerable overhead to the Modernisation Platform team.

#### Applications run configuration management using their own pipelines and tooling, MP provides access

This allows the application teams to run configuration management however they want to, using the CICD access provided by the Modernisation Platform. This is more work for application teams, but it has the greatest flexibility.

## Decision

Applications will run configuration management using their own pipelines (not MP provided), accessing their accounts using the CICD access provided (currently the member-cicd user but soon to be changed to OIDC).

## Consequences

- Application teams will need to build their own configuration management pipelines in the tools of their choice.
- Configuration management code can still be stored in the [modernisation-platform-configuration-management](https://github.com/ministryofjustice/modernisation-platform-configuration-management) repository and pulled from there if teams need a central location to store and reuse code.
- Modernisation Platform team may need to increase the permissions provided to the CICD access, this should be done as and when requested and discussed in the team to ensure permissions are appropriate.

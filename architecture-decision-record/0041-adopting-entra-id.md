# 41. Adopting Entra ID

Date: 2026-02-13

## Status

✅ Accepted

## Context
We have always used GitHub Teams to enable access to our AWS Accounts because it is convenient for developers -- but GitHub is not an Enterprise Identity Access Management (IdAM) Solution.

Due to the growth of MoJ Digital and more non-developer users needing access to AWS services, the cost and complexity of solely using GitHub for access management became ineffective.

The MoJs more official Enterprise IdAM Solution is EntraID that is linked to their @Justice identity.

We now have a working solution for our users to use their @Justice identities to log into our platform via EntraID.

This solution was developed by Analytical Platform (as they had the most need for this solution) - although ongoing support will be through the Modernisation Platform in collaboration with the Hosting Leads.


## Options

#### 1. Do not adopt Entra ID into service

##### Pros

- One less service to look after
- Maintenance stays with another team

##### Cons

- Reduced control over how access is managed, which could lead to security gaps

#### 2. Take Entra ID into service

If we choose this option, we need to consider two things. First, whether we want to standardize the programming language between the two jobs (one currently uses Node.js and the other uses Python) or keep them different. Second, group creation is currently open to anyone, so we need a way to approve groups as well as create them, potentially through ServiceNow.

##### Pros

- Direct control of the code and its maintenance
- Better support for user requests
- Opportunity to design a safe process for Entra ID group creation with line manager approval

##### Cons

- Another service for the team to own and support
- May require integration with ServiceNow for group creation workflows

## Language comparison for sync scripts

### Python

#### Pros

- Strong AWS SDK support with `boto3` and clear Identity Store examples
- Fewer dependencies for GraphQL + AWS orchestration
- Readable for data reconciliation and pagination flows
- Common in platform automation, which simplifies onboarding

#### Cons

- GitHub App auth requires manual JWT + token handling
- If the team is Node-first, this adds another runtime to maintain

### Node.js

#### Pros

- Octokit is first-class for GitHub App auth and GraphQL pagination
- Single runtime if existing tooling is already in Node
- Familiar for engineers already working on JS tooling

#### Cons

- AWS SDK v3 is more verbose for Identity Store operations
- More moving parts for pagination and retries across AWS/GitHub calls
- Less common for infra automation in this repo, which can slow support

## Decision

We will take the Entra ID service into the Modernisation Platform. This gives us direct control over access management, lets us respond to user requests more effectively, and ensures the service aligns with platform security and support standards. As part of this, we will decide whether to standardise the sync jobs on a single language and design an approval workflow for group creation (likely via ServiceNow).


## Consequences

- The platform team becomes responsible for ongoing maintenance and support
- We need to define and implement a secure group creation approval process
- We must decide whether to consolidate the sync jobs onto one language or maintain both


# 22. Patching Strategy

Date: 2022-10-12

## Status

✅ Accepted

## Context

The Modernisation Platform will end up hosting much of the MoJs legacy infrastructure, like any software, this will need patching and updates to ensure the software is secure. We need a strategy to ensure we stay patched and up-to-date. We held a team session to discover what we are currently patching and discuss what we could be patching. The Miro board output of the session can be found [here](https://miro.com/app/board/uXjVPPdFVPU=/). The findings are summarised below.

## Patching and updating we currently do as a platform

| Patch / Update                | Method                                                              | Scope                  | Example |
| ----------------------------- | ------------------------------------------------------------------- | ---------------------- |---|
| Github Actions                | Dependabot                                                          | Platform and user code |[Example](https://github.com/ministryofjustice/modernisation-platform/blob/main/.github/dependabot.yml#L7)|
| Terraform module dependancies | Dependabot                                                          | Platform and user code |[Example](https://github.com/ministryofjustice/modernisation-platform/blob/main/.github/dependabot.yml#L14)|
| Golang Code                   | Dependabot                                                          | Platform code          |[Example](https://github.com/ministryofjustice/modernisation-platform/blob/main/.github/dependabot.yml#L230)|
| Terraform                     | Auto upgrades for minor releases, issues raised for major releases. | Platform and user code |[Example](https://github.com/ministryofjustice/modernisation-platform/blob/main/terraform/environments/versions.tf#L4)|
| Terraform Providers           | Ad-hoc as new versions released                                     | Platform code          |[Example](https://github.com/ministryofjustice/modernisation-platform/blob/main/terraform/environments/versions.tf#L4)|
| Documentation                 | Daniel the manual spaniel Slack bot                                 | Platform documentation |[Example](https://github.com/ministryofjustice/tech-docs-monitor/blob/main/Rakefile#L9)|
| SCA Tools                     | Always pull from latest                                             | Platform and user code |[Example](https://github.com/ministryofjustice/github-actions/blob/main/terraform-static-analysis/entrypoint.sh#L21)|
| Platform Bastions             | Whenever Terraform is run                                           | User code              |[Example](https://github.com/ministryofjustice/modernisation-platform-terraform-bastion-linux/blob/main/main.tf#L352)|

## Patching and updating we want to investigate

### Bastions picking up the latest version

The bastions currently only update to the latest version when the Terraform is run. We want them to automatically update when they rebuild every night to the latest version.

<https://github.com/ministryofjustice/modernisation-platform/issues/1385>

### Terraform Providers

We currently do this on an ad-hoc basis, we need a better way to make sure we are aware of and apply Terraform provider updates.

<https://github.com/ministryofjustice/modernisation-platform/issues/2410>

### EC2 Patching

We want to be able to patch EC2s hosted on the platform at a platform level. We will start with identifying what patching should be done on instances and make this information available to application teams to fix or mitigate. We will reserve the right to patch users instances if we feel there is a significant risk which needs to be addressed immediately. We will support unpatched / old instances if there is a valid business case and the instance does not put the platform or the wider MoJ at risk.

<https://github.com/ministryofjustice/modernisation-platform/issues/2411>

### RDS Patching

We want to be able to patch RDS instances hosted on the platform at a platform level. We will start with identifying what patching should be done on instances and make this information available to application teams to fix or mitigate. We will reserve the right to patch users instances if we feel there is a significant risk which needs to be addressed immediately. Users should note that minimum versions of RDS are required by AWS and must keep in line with this version or the instance will be automatically updated by AWS.

<https://github.com/ministryofjustice/modernisation-platform/issues/2412>

### ECS/EKS Nodes

Where ECS or EKS use EC2 instances, we need to ensure that they are using the latest recommended versions. We will start with investigating how we find out the latest versions and make users aware of this, then how we make these upgrades at a platform level if needed.

<https://github.com/ministryofjustice/modernisation-platform/issues/2413>

### Hardened AMIs

Look in to creating hardened base AMIs which are maintained at a platform level, users can then use these AMIs to build their own images.

<https://github.com/ministryofjustice/modernisation-platform/issues/2414>

## Consequences

- [x] Create tickets for the above investigations
- [ ] To apply patching we will need the [SSM agent installed on user instances](https://github.com/ministryofjustice/modernisation-platform/issues/2415)

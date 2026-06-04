# 21. Use a Go Lambda for instance scheduling

Date: 2022-10-05

## Status

✅ Accepted

## Context

As part of the platform's [sustainability](https://user-guide.modernisation-platform.service.justice.gov.uk/user-guide/sustainability.html) goals, we want to shut down non production instances outside of working hours to save money and energy.

We want the scheduling to work across multiple accounts, and to be flexible enough to allow user to opt out, or use schedule times by tagging.

We completed a [spike](https://github.com/ministryofjustice/modernisation-platform/issues/1091) and came up with several options on how to achieve this.

## Options

### Option 1 - Use a third party Lambda

We looked at a 3rd party Lambda written in Python and Terraform - <https://github.com/diodonfrost/terraform-aws-lambda-scheduler-stop-start>

| Pros                         | Cons                                                                                                                                                                                                             |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| It does roughly what we want | Modifications will still be needed for multi account use and to adjust schedules                                                                                                                                 |
| Works with older instances   | We have limited Python skills and it's not one of our [core languages](https://github.com/ministryofjustice/modernisation-platform/blob/main/architecture-decision-record/0019-use-bash-go-as-core-languages.md) |
|                              | Security risk of using a third party Lambda                                                                                                                                                                      |

### Option 2 - Use AWS Instance Scheduler

Use the [AWS Instance Scheduler](https://aws.amazon.com/solutions/implementations/instance-scheduler/) solution.

| Pros                 | Cons                                                              |
| -------------------- | ----------------------------------------------------------------- |
| It does what we want | It is in CloudFormation                                           |
|                      | Wouldn't work for older instances without the SSM Agent installed |

In order to use it we would either have to start supporting CloudFormation stacks, or rewrite the CloudFormation stack to Terraform. We started to rewrite the the stack, but soon realised this would be very hard to do, and hard to maintain going forward.

### Option 3 - Use AWS Systems Manager

Platform users had already started to use [AWS Systems Manager](https://aws.amazon.com/systems-manager/) for their local scheduling of EC2s.

| Pros                 | Cons                                                              |
| -------------------- | ----------------------------------------------------------------- |
| It does what we want | Wouldn't work for older instances without the SSM Agent installed |
|                      | Doesn't scale well over multiple accounts                         |

### Option 4 - Create a custom Lambda using Go

| Pros                            | Cons                                                  |
| ------------------------------- | ----------------------------------------------------- |
| It does what we want            | New challenges with working with and deploying Lambda |
| Works with older instances      | Additional code to maintain                           |
| Go is a core language           |                                                       |
| Flexibility to change as needed |                                                       |

## Decision

Option 4, we will create a new custom Lambda using Go.

## Consequences

- Need to up-skill team members in Go (already underway)
- Need to figure out strategies for running Lambda locally
- Need to figure out strategies for testing Lambda
- Need to figure out strategies for deploying Lambda

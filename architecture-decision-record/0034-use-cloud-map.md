# 33. Use of AWS Cloud Map

Date: 2024-12-01

## Status

❌ Rejected

## Context

AWS Cloud Map is a service that allows resources such as ECS, Lambda, EC2, and DynamoDB to communicate with each other via a shared namespace. While it provides a robust service discovery mechanism, it also grants extensive permissions to the end user, including a VPC that is shared via RAM (Resource Access Manager) share, which can lead to potential security risks.

## Decision

We have decided not to adopt AWS Cloud Map for our service discovery needs. The primary reason for this decision is the excessive permissions that AWS Cloud Map requires the end user to have against the shared VPC, which could lead to security vulnerabilities and unauthorized access to critical resources.

## Consequences

### General consequences

* We will need to explore alternative service discovery mechanisms that provide a more secure permission model.

### Advantages

* Improved security by limiting the permissions granted to end users.
* Reduced risk of unauthorized access to critical resources.

### Disadvantages

* Additional effort required to implement and maintain an alternative service discovery solution.
* Potentially higher costs if alternative solutions are more expensive than AWS Cloud Map.
* Possible delays in project timelines due to the need to evaluate and integrate a new service discovery mechanism.

## Alternatives

1. **Same VPC Communication**: If the resources are in the same VPC and the EC2 instances are open to each other on the required port, one instance can call the other depending on what the container is listening on. If both containers are on the same EC2 instance, using `docker inspect` can get the private IP, which will be the same for both. Using a Route 53 address for each EC2 instance is the most straightforward approach.

2. **Environment Variables in ECS Task Definition**: Another approach is to declare a variable in the ECS task definition that captures the Terraform property of the EC2 private IP. This variable is then accessible to the container as an OS environment variable.
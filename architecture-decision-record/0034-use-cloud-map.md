# 33.  Use of AWS cloud map

Date: 2024-12-01

## Status

❌ Rejected

## Context

AWS Cloud Map is a service that allows resources such as ECS, Lambda, EC2, and DynamoDB to communicate with each other via a shared namespace. While it provides a robust service discovery mechanism, it also grants extensive permissions to the end user, which can lead to potential security risks.

## Decision

We have decided not to adopt AWS Cloud Map for our service discovery needs. The primary reason for this decision is the excessive permissions that AWS Cloud Map grants to the end user, which could lead to security vulnerabilities and unauthorized access to critical resources.

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
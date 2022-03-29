# 18. Use AWS Shield Advanced

Date: 2022-03-29

## Status

✅ Accepted

## Context

We want to ensure that we have the best protection against DDoS for applications hosted on the Modernisation Platform.

This should include:

- Protection against layer 3 and 4 attacks
- Protection against layer 7 attacks
- Monitoring and alerting so that we know when we are being attacked
- Protection of all public facing interfaces
- Be able to manage the implementation easily across the platform


An investigation into the value of AWS Shield Advanced was completed [here](https://github.com/ministryofjustice/modernisation-platform/issues/1601).

## Decision

We will use AWS Shield Advanced for the Modernisation Platform

## Consequences

### General consequences

AWS Shield will need to be implemented at an AWS organisation level.  In order to automate the enrolling of accounts we will also need to configure AWS Firewall Manager for the organisation. At an organisation level we will need to either configure policies and apply them to the various AWS accounts, or let users know that AWS Shield Advanced is now available and how to configure policies to use it. Route 53 and Global Accelerator is not supported in Firewall Manager and will need to be configured individually.

For the platform, we will need to decide on policies and how to apply them.

### Advantages

* We can apply policies by OU and tagging to automatically enroll resources to use Shield Advanced
* Advanced Layer 3 and 4 DDoS protection
* Layer 7 automatic mitigation for Cloudfront
* Protect all interfaces not covered by Shield Standard, such as EC2s and Network Load Balancers
* DDoS specific metrics
* AWS Shield Response team support during DDoS attacks
* Cost protection - we can claim back usage costs after an attack
* We can manage WAF at the organisation or platform level
* We can use Terraform to write Firewall Manger policies

### Disadvantages

* $3,000 per month (although this is an organisation level costs, all MoJ AWS accounts will be able to use)
* Usage costs
* Route 53 Shield configuration will need to be managed in code at an account level

# 30. Cross environment network access

Date: 2024-01-22

## Status

✅ Accepted

## Context

Applications migrated to the Modernisation Platform will at times want to access data stored in other Modernisation Platform applications.

This can be done relatively simply when both accounts are part of the same business unit and same environment, as they will share the same underlying VPC.
However, this is more complicated when applications are in different business units or environments. The Modernisation Platform is not configured to allow
east-west traffic flows, which prevents this level of network access.

## Decision

Customers will be free to make their own choices when using applications in the same business unit and environment. EG, directly querying an RDS database
or calling an API endpoint.

Customers will use cloud-native approaches when using applications in different business units or accounts. EG, sharing RDS database or EC snapshots
between accounts, or creating AWS PrivateLink endpoints to allow cross-account access to APIs.

## Consequences

- Modernisation Platform team will resolve platform restrictions if customers have difficulty using PrivateLink endpoints.
- Customers will make use of cloud-native approaches to cross-account access.
- Using PrivateLink will prevent traffic from passing through Transit Gateway or Network Firewall, allowing the customer to own their security configuration.

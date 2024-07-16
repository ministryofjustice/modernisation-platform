# 30. NCSC PDNS will not be applied at platform level

Date: 2024-07-10

## Status

🤔 Proposed

## Context

Implementation of National Cyber Security Centre (NCSC) Protective Domain Name Services (PDNS) has been suggested as a technology to implement to improve the security of platform customers.

We investigated this as part of issue [#6121](https://github.com/ministryofjustice/modernisation-platform/issues/6121).

## Options

### 1. Implement PDNS

#### Pros

- Free-to-use
- Supplied by trusted government partner

#### Cons

- On-premise-centric approach
- Expects a small number of DNS servers to forward requests on
- Requires us to route all DNS requests through platform out to PDNS endpoints
- No ability to manage through code
- Not likely to be applied at a platform level

### 2. Implement AWS Route53 Resolver DNS Firewall

#### Pros

- Cloud-centric approach
- Can be managed through code
- Allows us to include customisations
- Can be applied at platform level

#### Cons

- Not free-to-use
- Solution is not portable

## Decision

Implementing PDNS is not appropriate at a platform level; from our investigation the solution is geared towards an organisation-wide approach, but the way that agencies are federated into the MoJ as a whole makes this unsuitable for us.
Implementing AWS Route53 Resolver DNS Firewall offers a comparable level of protection that can be applied at a platform level.

## Consequences

- Modernisation Platform will not implement NCSC PDNS
- Modernisation Platform team will scope implementation of AWS Route53 DNS Resolver Firewall

# 16. IP Address Range Allocation

Date: 2021-11-18

## Status

✅ Accepted

## Context

The Modernisation Platform needs to be able to communicate privately with various other areas of the MoJ. The main use cases are as follows:

- Access from various MoJ sites to the platform
- Access from VPNs for remote devices to the platform
- Connectivity from a business units existing hosting to the platform during migration
- Connectivity from a business units existing hosting to the platform for applications not yet migrated
- Connectivity to other MoJ hosting platforms

This connectivity between different networks is provided by the MoJ Transit Gateway. In order to enable to required routing we need to ensure that our IP range allocation is unique to avoid overlaps or clashes.

Our current IP ranges are not being managed centrally and we have identified some clashes with existing networks.

## Decision

The Modernisation Platform will be allocated IP ranges from the Network Operations Team and Vodafone who maintain the MoJ record of IP ranges. This will avoid clashes with any existing or future infrastructure registered in the same way.

## Consequences

- We will use the following IP ranges that have been allocated to us:

```YAML
10.20.0.0/16
10.26.0.0/16
10.27.0.0/16
```

- We will split these IP ranges according to our [CIDR Allocation documentation](https://github.com/ministryofjustice/modernisation-platform/blob/main/cidr-allocation.md), more details on how this is split can be found in our [networking concepts pages](https://user-guide.modernisation-platform.service.justice.gov.uk/concepts/networking/subnet-allocation.html#subnet-allocation).
- We cannot control the private IP ranges of business units which are not managed by the MoJ centrally. This means that we could potentially still face overlaps with different business units. If this occurs we will have to deal with it then.
- In order to use the new ranges we will have to rebuild our existing infrastructure.

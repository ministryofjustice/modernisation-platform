# 28. Expand the Scope of the Platform

Date: 2023-11-14

## Status

✅ Accepted

## Context

The Modernisation Platform was originally developed with the intention that it would only be used for migrating legacy applications to a strategic cloud platform, where they could not be hosted in the [Cloud Platform](https://github.com/ministryofjustice/cloud-platform).  Applications would then be hosted on the Modernisation Platform until they were modernised and moved to the Cloud Platform, replaced with newer applications, or decommissioned.

As the platform has developed and grown, we have encountered scenarios where new services (applications or platforms) are required, but the Cloud Platform is not able to host them. Examples of this include other hosting platforms, and applications using AWS services which have certain technical requirements which cannot run on the Cloud Platform, and there are no Cloud Platform compatible alternatives.  There is also a greater understanding now that some applications which were thought to be decommissioned are likely to remain for many years.

## Options

### 1. Create another platform for services which can't be hosted on the Cloud Platform

**Pros**

- Dedicated platform for non container related workflows

**Cons**

- Will likely be extremely similar to the Modernisation Platform
- New team required to build and maintain
- Expensive

### 2. Only allow services which can be hosted on the Cloud Platform

**Pros**

- Consistent infrastructure throughout the MoJ
- No additional work required
- No need for an additional platform

**Cons**

- Forces teams to use technologies which may not fit the application
- Still have long term legacy applications requiring the Modernisation Platform
- Places more pressure on the Cloud Platform to host different technologies

### 3. Give AWS accounts directly to services teams

**Pros**

- Well it's an option

**Cons**

- Goes against hosting strategy
- Teams responsible for building entire AWS infrastructure, landing zones etc
- A step backwards towards the cloud wild west

### 4. Services (applications or platforms) which can be hosted on the Cloud Platform must be, but if there is a valid reason why they can't, then services can be hosted on the Modernisation Platform

**Pros**

- Platform already in place and able to support most services
- Aligned with hosting strategy of platform teams
- Consistency and standards across applications and platforms

**Cons**

- Risk of unnecessary technologies being used
- Core infrastructure may need to be amended to support other platforms


## Decision

Option 4. The Cloud Platform will remain the primary hosting platform for the MoJ and services must be hosted there if they can be. If there is a valid reason that something cannot be hosted on the Cloud Platform, then the Modernisation Platform should be used.

## Consequences

- Modernisation Platform team will need to work closely with the Cloud Platform team to ensure that services are hosted in the correct platform.
- The Modernisation Platform may need to make changes to its core infrastructure for hosting other platforms.
- Modernisation Platform name is a bit misleading now, we may want to consider changing it.

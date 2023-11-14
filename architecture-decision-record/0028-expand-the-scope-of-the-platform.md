# 28. Expand the Scope of the Platform

Date: 2023-11-14

## Status

✅ Accepted

## Context

The Modernisation Platform was originally developed with the intention that it would only be used for migrating legacy applications to a strategic cloud platform, where they could not be hosted in the [Cloud Platform](https://github.com/ministryofjustice/cloud-platform).  Applications would then be hosted on the Modernisation Platform until they were either modernised and moved to the Cloud Platform, or decommissioned or replaced with newer applications.

As the platform has developed and grown, we have encountered scenarios where new applications are required, but the Cloud Platform is not able to host them. Examples of this include the Data Platform, and applications using certain AWS managed services such as Redshift.  There is also a greater understanding now that some applications which were thought to be decommissioned are likely to remain for main years.

## Options

### 1. Create another platform for new things which can't be hosted on the Cloud Platform

**Pros**

- Dedicated platform for non container related workflows

**Cons**

- Will likely be extremely similar to the Modernisation Platform
- New team to build required and maintain
- Expensive

### 2. Only allow new applications which can be hosted on the Cloud Platform

**Pros**

- Consistent infrastructure throughout the MoJ
- No additional work required

**Cons**

- Forces teams to use technologies which may not fit the application
- Still have long term legacy applications requiring the Modernisation Platform
- Places more pressure on the Cloud Platform to host different technologies

### 3. Give AWS accounts directly to applications

**Pros**

- Well it's an option

**Cons**

- Goes against hosting strategy
- Teams responsible for building entire AWS infrastructure, landing zones etc
- A step backwards towards the cloud wild west

### 4. New applications and platforms can be hosted on the Modernisation Platform if not suitable for the Cloud Platform

**Pros**

- Platform already in place and able to support most applications
- Aligned with hosting strategy of platform teams
- Consistency and standards across applications and platforms

**Cons**

- Risk of unnecessary technologies being used
- Core infrastructure may need to be amended to support other platforms


## Decision

Option 4. The Cloud Platform will remain the primary hosting platform for the MoJ. If there is a valid reason that something cannot be hosted on the Cloud Platform, then the Modernisation Platform should be used.

## Consequences

- Modernisation Platform team will need to work closely with the Cloud Platform team to ensure that applications are hosted in the correct platform.
- The Modernisation Platform may need to make changes to its core infrastructure for hosting other platforms.
- Modernisation Platform name is a bit misleading now, we may want to consider changing it.

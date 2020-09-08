# 1. Record architecture decisions

Date: 2020-09-04

## Status

✅ Accepted

## Context

As we build the Modernisation Platform, we will collectively making decisions around the architecture, processes, and tooling for the Modernisation Platform.

When making these decisions, we should record them, both to help us understand and remember why we made them, and to also act as a reference for onboarding new team members and for anyone who is interested to view.

Finally, as outlined in the [Government Design Principles](https://www.gov.uk/guidance/government-design-principles), these should be publicly accessible as [making things open makes things better](https://www.gov.uk/guidance/government-design-principles#make-things-open-it-makes-things-better).

## Decision

We will use Architecture Decision Records, as described by Michael Nygard in the article "[Documenting architecture decisions](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions)".

## Consequences

Michael Nygard's article, linked above, talks about the following consequences:

- One ADR describes one significant decision for a specific service. It should be something that has an effect on how the rest of the service will run.
- The consequences of one ADR are very likely to become the context for subsequent ADRs. This is also similar to [Alexander's idea of a pattern language](http://wiki.c2.com/?AlexandrianForm): the large-scale responses create spaces for the smaller scale to fit into.
- Developers and service stakeholders can see the ADRs, even as the team composition changes over time.
- The motivation behind previous decisions is visible for everyone, present and future. Nobody is left scratching their heads to understand, "What were they thinking?" and the time to change old decisions will be clear from changes in the service's context.

# 20. How we create and maintain documentation

Date: 2022-09-06

## Status

✅ Accepted

## Context

As we build the Modernisation Platform, we should document how the platform is built, along with any repeating activities that Modernisation Platform engineers or users need to perform.

## Decision

### Location

All user and team guidance should be stored in the open in our user guidance [here](https://user-guide.modernisation-platform.service.justice.gov.uk)

Guidance or documentation directly relating to code should be stored in a `README.MD` next to the code.

The exception to this is any sensitive information, or information on users of the platform which should be stored in [Google Drive](https://drive.google.com/drive/folders/1FaYhbFK68o_W4doGX7mZqR4dU3OrhuOl)

### Maintenance

We should regularly review the user guidance, with reminders to review at set intervals with [https://github.com/ministryofjustice/tech-docs-monitor](https://github.com/ministryofjustice/tech-docs-monitor).

In the definition of done for every issue there is the following to remind people to update documentation after any changes:

- [ ] readme has been updated
- [ ] user docs have been updated

### Diagrams

Diagrams should be created in our [app.diagrams.net](https://app.diagrams.net/#G1w8dZs5vZOoy0dvCnRr5P6GHc3VQRdwLq) diagram, once they are complete they should be exported as a PNG and published on the user guidance website. Any amendments to diagrams in app.diagrams.net should be updated on the guidance website.

### Guidance website sections

#### User Guide

The user guide section is for guidance to be used by platform users.

The getting started section is used for a quick run through of the tasks needed to get an application up and running. This should only include the most basic tasks which everyone must do.

The how to guides provide information on other tasks which platform users may need to undertake, or more detailed information on basic tasks.

#### Concepts

This section goes into detail on how the platform works, including the background and design considerations.

#### Modernisation Platform Team Information

This providers information about our team, including who we are, how we work and our operational processes.

#### Runbooks

This is guidance for internal Modernisation Platform team use, and includes information such as how to guides and runbooks.

#### Getting Help

How to contact us.

## Consequences

Since the majority of our guidance is open to the public we need to ensure that we do not publish any sensitive details or user data in text or screenshots.

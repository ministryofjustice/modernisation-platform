# Service Runbook Template

This is a template that should be populated by the development team when moving to the modernisation platform, but also reviewed and kept up to date.

## What you should include in your service’s runbook

To ensure that people looking at your runbook can get the information they need quickly, your runbook should be short but clear. Throughout, only use acronyms if you’re confident that someone who has just been woken up at 3am would understand them.

*If you have any questions surroudning this page please post in the `#ask-modernisation-platform` channel.*

## Mandatory Information
* __Last review date:__ The date your service’s runbook was last checked to be accurate.
* __Description:__ A short (less than 50 word) description of what your service does, and who it’s for.
* __Service URLs:__ The URL(s) of the service’s production environment(s).
* __Incident response hours:__ When your service receives support for urgent issues. This should be written in a clear, unambiguous way. For example: 24/7/365, Office hours, usually 9am-6pm on working days, or 7am-10pm, 365 days a year.
* __Incident contact details:__ How people can raise an urgent issue with your service. This must not be the email address or phone number of an individual on your team, it should be a shared email address, phone number, or website that allows someone with an urgent issue to raise it quickly.
* __Service team contact:__ How people with non-urgent issues or questions can get in touch with your team. As with incident contact details, this must not be the email address or phone number of an individual on the team, it should be a shared email address or a ticket tracking system.
* __Hosting environment:__ If your service is hosted on another MOJ team’s infrastructure, link to their runbook. If your service has another arrangement or runs its own infrastructure, you should list the supplier of that infrastructure (ideally linking to your account’s login page) and describe, simply and briefly, how to raise an issue with them.


## Optional
* __Other URLs:__ If you can, provide links to the service’s monitoring dashboard(s), health checks, documentation (ideally describing how to run/work with the service), and main GitHub repository.
* __Expected speed and frequency of releases:__ How often are you able to release changes to your service, and how long do those changes take?
* __Automatic alerts:__ List, briefly, problems (or types of problem) that will automatically alert your team when they occur.
* __Impact of an outage:__ A short description of the risks if your service is down for an extended period of time.
* __Out of hours response types:__ Describe how incidents that page a person on call are responded to. How long are out-of-hours responders expected to spend trying to resolve issues before they stop working, put the service into maintenance mode, and hand the issue to in-hours support?
* __Consumers of this service:__ List which other services (with links to their runbooks) rely on this service. If your service is considered a platform, these may be too numerous to reasonably list.
* __Services consumed by this:__ List which other services (with links to their runbooks) this service relies on.
* __Restrictions on access:__ Describe any conditions which restrict access to the service, such as if it’s IP-restricted or only accessible from a private network.
* __How to resolve specific issues:__ Describe the steps someone might take to resolve a specific issue or incident, often for use when on call. This may be a large amount of information, so may need to be split out into multiple pages.

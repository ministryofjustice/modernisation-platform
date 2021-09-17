---
name: New Modernisation Platform Environment
about: Request a new Modernisation Platform Environment
labels: onboarding
---

<!-- Please complete the following details and submit the new issue -->

## Environment details

### Application Name

<!--
The name of your application, please follow MoJ guidance for naming things
https://ministryofjustice.github.io/technical-guidance/documentation/standards/naming-things.html#naming-things
-->

### Github team slug

<!-- The name of your github team for environment access -->

### Environments

<!-- 
Which environments would you like for your application 
(we recommend production and one non production environment if possible) 
-->

- [ ] Development
- [ ] Test
- [ ] Preproduction
- [ ] Production

### Tags

<!-- 
These will be used to tag your AWS resources, for further details on tagging please see here 
https://ministryofjustice.github.io/technical-guidance/documentation/standards/documenting-infrastructure-owners.html#tags-you-should-use

The is-production tag will be inferred from the environment and is not needed here
-->

tag | value
--- | ---
application | 
business-unit | 
owner | 

<!-- 
Valid business-unit values
HQ,HMPPS,OPG,LAA,HMCTS,CICA,Platforms,CJSE,Probation
-->

## Networking options

### Connectivity

<!-- Please detail here and connectivity that your application needs, eg to other applications or external parties -->

### Additional features

<!-- 
Please check any additional features required. For more information see here
https://user-guide.modernisation-platform.service.justice.gov.uk/user-guide/creating-networking.html#certificate-services
-->

- [ ] Bastion
- [ ] Additional VPC Endpoints
- [ ] Extended DNS Zones

## Other information

<!-- Any other information you feel is relevant, please remember this is a public repository -->

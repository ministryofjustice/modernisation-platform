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

### GitHub team slug

<!-- The name of your github team for environment access, this github team must be part of the ministryofjustice github organisation -->

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
HQ,HMPPS,OPG,LAA,HMCTS,CICA,Platforms,CJSE
-->

## Networking options

### Connectivity

#### Subnet sets

<!--Please choose one of the below, most applications will use the general subnet set for their business unit. This means that they will benefit from out of the box connectivity to other applications, most applications will use the general subnet.  If an application has highly sensitive data it may need to go into a subnet with limited connectivity. -->

- [ ] General - this application will use the same subnet as other applications in your business unit
- [ ] Isolated - this application has highly sensitive data which must have its own isolated subnet

#### How do users connect to the application?

- [ ] Over the public internet
- [ ] With a purple cabled device (please give details)
- [ ] With a MoJ Official device

#### Connectivity to other applications or external parties

<!-- Please detail here and connectivity that your application needs, eg to other applications or external parties -->

## Additional features

<!-- 
Please check any additional features required. For more information see here
https://user-guide.modernisation-platform.service.justice.gov.uk/user-guide/creating-networking.html#certificate-services
If you are not sure you can leave these blank and they can be added at a later date
-->

- [ ] Additional VPC Endpoints
- [ ] Extended DNS Zones
- [ ] Other - please specify

## Other information

<!-- Any other information you feel is relevant, please remember this is a public repository -->

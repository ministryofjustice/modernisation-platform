---
name: New Modernisation Platform Environment
about: Request a new Modernisation Platform Environment
labels: ["onboarding", "member request"]
---

<!-- Please complete the following details and submit the new issue -->

## Environment details

### Application Name

<!--
The name must be in lowercase and a maximum of 30 characters
The name of your application, please follow MoJ guidance for naming things
https://ministryofjustice.github.io/technical-guidance/documentation/standards/naming-things.html#naming-things
-->

### Description of application

<!--
Brief description of the application and what it looks like.
What does the application do?
What technologies does it use?
-->

### GitHub team slug

<!-- 
The name of your GitHub team for environment access, this github team must be part of the ministryofjustice github organisation.
You can have multiple GitHub teams with different access levels if required.
-->

### Environments

<!-- 
Which environments would you like for your application 
(we recommend production and one non production environment if possible)
The access level determines what actions you can do in the AWS console, see here for more information:
https://user-guide.modernisation-platform.service.justice.gov.uk/user-guide/creating-environments.html#access
Choose one access level per environment.
-->

| Environment   | Access level |
| ---     | --- |
|<ul><li>[ ] Development</li></ul> | <ul><li>[ ] view-only</li><li>[ ] developer</li><li>[ ] sandbox</li></ul> |
|<ul><li>[ ] Test</li></ul>   | <ul><li>[ ] view-only</li><li>[ ] developer</li></ul> |
|<ul><li>[ ] Preproduction</li></ul>| <ul><li>[ ] view-only</li><li>[ ] developer</li></ul> |
|<ul><li>[ ] Production</li></ul> | <ul><li>[ ] view-only</li><li>[ ] developer</li></ul> |

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
infrastructure-support |
owner |


<!-- 
Valid business-unit values
HQ,HMPPS,OPG,LAA,HMCTS,CICA,Platforms,CJSE

The infrastructure-support tag should be an email address which will receive AWS Health Operations emails.
-->

## Networking options

### Subnet sets

<!--Please choose one of the below, most applications will use the general subnet set for their business unit. This means that they will benefit from out of the box connectivity to other applications, most applications will use the general subnet.  If an application has highly sensitive data it may need to go into a subnet with limited connectivity. -->

- [ ] General - this application will use the same subnet as other applications in your business unit
- [ ] Isolated - this application has highly sensitive data which must have its own isolated subnet with no network connectivity

### Firewall rules

<!-- Modernisation Platform uses firewall for traffic coming in privately from the wider MoJ network (for applications that are not publicly accessible). Connectivity from outside the Modernisation Platform will be blocked by default by the firewall. Please specify any firewall rules your application may require to allow access from other applications, tools or external parties. Firewall rules should be provided in a form of CIDR ranges, protocols and ports (see example below). If you specify an insecure port/service/protocol, you will need to provide a business justification and make the service owner aware of its vulnerabilities. -->

    # e.g.
    "cp_to_mp_hmpps_test": {"
      "action": "PASS",
      "source_ip": "172.20.0.0/16",
      "destination_ip": "10.26.8.0/21",
      "destination_port": "443",
      "protocol": "TCP"
    },

### How do users connect to the application?

- [ ] Over the public internet
- [ ] With a purple cabled device (please give details)
- [ ] With a MoJ Official device

### Connectivity to other applications or external parties

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

## Definition of done

<!-- Checklist for definition of done and acceptance criteria, for example: -->

- [ ] account created
- [ ] customer informed
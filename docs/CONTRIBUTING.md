# Introduction

The purpose of this document is to show contributors to the modernisation platform code the best practises and testing that should be undertaken. Code should be in Terraform and tests, if coded, in Go.

## Code of Conduct

The Ministry of Justice [Code of Conduct](https://github.com/ministryofjustice/.github/blob/main/CODE_OF_CONDUCT.md) is used to govern the project and those participating.
Please report unacceptable behavior to the maintainers or administrators.

## Standards

We follow the [MoJ Technical Guidance](https://technical-guidance.service.justice.gov.uk/#moj-technical-guidance),
which complements the Service Standard,
and also the MoJ [Cyber and Technical Security Guidance](https://security-guidance.service.justice.gov.uk/#cyber-and-technical-security-guidance).

# Modernisation Platform Documentation
To access the modernisation documentation follow this [MP Documentation](https://user-guide.modernisation-platform.service.justice.gov.uk/#modernisation-platform).
For the general terraform you can access here [Terraform](https://user-guide.modernisation-platform.service.justice.gov.uk/runbooks/terraform.html)
If you are interested in running Terraform locally try [Running Terraform Plan Locally](https://user-guide.modernisation-platform.service.justice.gov.uk/user-guide/running-terraform-plan-locally.html#running-terraform-plan-locally)

These can be located by running a search in the documentation [MP Documentation](https://user-guide.modernisation-platform.service.justice.gov.uk/#modernisation-platform). 

# Coding examples

There are a number of examples in this repository of coding and also addutional ones in the modernisation-platform-environments repository. One are we recommend users exmaine is the example code in moderisation-platform-environments/terrafor/environments//example area. This has sameples of code showing how to build and ec2, security groups, load blanacnders, rds and others. These are named well and the code can be copied and pasted into your own code so they are available locally. Obviously when these are copied the names should be changed so they do not contain the example names.

For details on what Terraform consider to be best practices see their [information](https://www.terraform-best-practices.com/)

Always ensure that the terraform code is checked prior to pushing it to make a pull request. It is best to plan the code (do NOT apply) to make sure there are no errors. To do this run a terraform init (in the correct location for the code) and then pick out the correct workspace using terraform workspace list, select the correct one and run terraform workspace select the-one-you-want. Once this is complete run a terraform plan. If there are any errors at the init or plan stage then correct those before continuing. 

Once the plan runs and shows the changes you expect you can raise a pull request (via gid add . - **in a new branch** -, git commit -m "some comments" and a git push).
For more information on the working in [Github](https://github.com/github/docs/blob/main/contributing/working-in-docs-repository.md). This provides documentation on various aspects on Github usage and administration.

# Platform modules

There are a number of areas where you can contribute to the modernisation platform modules. The majority of these pieces of code are in the modernisation-platform-environments repository and start with the word platform (e.g. platform-data). We would prefer that these are not amended but they can be if required. You must, however, follow our code standards as per the included code and included the in standards details above. Following these standards will provide consistency when the coding is examined.



<!--- BEGIN_TF_DOCS --->

<!--- END_TF_DOCS --->

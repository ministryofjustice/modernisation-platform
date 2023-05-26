# Introduction

The purpose of this document is to show contributors to the Modernisation Platform code the best practices and testing that should be undertaken. The code should be in Terraform and tests, if coded, in Go.

## Code of Conduct

The Ministry of Justice [Code of Conduct](https://github.com/ministryofjustice/.github/blob/main/CODE_OF_CONDUCT.md) is used to govern the project and those participating.
Please report unacceptable behavior to the maintainers or administrators.

## Standards

We follow the [MoJ Technical Guidance](https://technical-guidance.service.justice.gov.uk/#moj-technical-guidance),
which complements the Service Standard,
and also the MoJ [Cyber and Technical Security Guidance](https://security-guidance.service.justice.gov.uk/#cyber-and-technical-security-guidance).

# Modernisation Platform Documentation
To access the modernisation documentation follow this [MP Documentation](https://user-guide.modernisation-platform.service.justice.gov.uk/#modernisation-platform).
For the general terraform you can access [here](https://user-guide.modernisation-platform.service.justice.gov.uk/runbooks/terraform.html)
If you are interested in running Terraform locally try [Running Terraform Plan Locally](https://user-guide.modernisation-platform.service.justice.gov.uk/user-guide/running-terraform-plan-locally.html#running-terraform-plan-locally)

These can be located by running a search in the documentation [MP Documentation](https://user-guide.modernisation-platform.service.justice.gov.uk/#modernisation-platform). 

# Coding examples

There are several examples in this repository of coding and also additional ones in the modernisation-platform-environments repository. One, which we recommend to users to examine, is the example code in moderisation-platform-environments/terraform/environments/example files. This has samples of code showing how to build ec2, security groups, load balancers, rds and others. These are named well and the code can be copied and pasted into your own code so they are available locally. When these are copied the names should be changed so they do not contain the example names.



For details on what Terraform consider to be best practices see their [information](https://www.terraform-best-practices.com/)

# Checking Code

Always ensure that the terraform code is checked before pushing it. It is best to plan the code (**NEVER** apply) to make sure there are no errors. To do this run a *terraform init* (in the correct location for the code) and then pick out the correct workspace using terraform workspace list. Select the correct workspace by running *terraform workspace select the-workspace-you-want*. Once this is complete run a *terraform plan*. If there are any errors at the init or plan stage then correct those before continuing. 

Once the plan runs without issue AND shows the changes you expect you can raise a pull request (via *gid add .* - **in a new branch** -, *git commit -m "some comments"* and a *git push* which may show the full command you need in the text beforehand).
It is assumed that users will know about using git commands but more information can be found on the working of [GitHub](https://github.com/github/docs/blob/main/contributing/working-in-docs-repository.md). This provides documentation on various aspects of GitHub usage and administration.

# "Platform" code

There are several areas where you can contribute to the modernisation platform code. The majority of these pieces of code are in files in the modernisation-platform-environments repository and start with the word platform (e.g. platform-data.tf). **We would prefer that these are not amended** but they can be if **absolutely** required. You must, however, follow our code standards as per the written code and included in the standards detailed above. Following these standards will provide consistency when the coding is examined.

If you need additional items in the "platform" files the Modernisation Platform Team would prefer you to create another file alongside the "platfom" one. So, in the example above, create a data.tf alongside the platform-data.tf file.

## Modules 
You may create code in a module under your particular folder in modernisation-platform-environments repository. To do this you should first create a folder called modules and then add additional folders as required. An example can be seen here.

![Exmaple Module Folder](source/images/module-folder.png)

Generally, a module will contain a minimum of 2 files 
- main.tf
- variables.tf

Additional files can be added as needed such as 
- outputs.tf
- iam.tf
- versions.tf

or more as needed.

Once the files are built and tested (see Checking code above) they can be deployed.

This code could, possibly, prove useful to other teams in the future. If that is the case please contact the Modernisation Platform Team. It may be that the code you are suggesting or would like to amend should be created as a module that can be used in any environment. If this is the case a module can be created and values passed in to allow its use everywhere. The Modernisation Platform Team can provide advice and create the module with you.


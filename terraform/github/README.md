# Modernisation Platform - GitHub

This directory creates and maintains the following GitHub items for the Modernisation Platform:

  - repositories
  - team membership
  - team access to repositories

The state is stored in S3, as defined in [backend.tf](backend.tf).

## How to create a new repository for a terraform module

Say that we want to create a new repository for a terraform module named `bastion-linux`. We need to add the following section to [main.tf](main.tf)

```
module "terraform-module-bastion-linux" {
  source      = "./modules/repository"
  name        = "modernisation-platform-terraform-bastion-linux"
  description = "Module for creating Linux bastion servers in member AWS accounts"
  topics = [
    "aws",
    "bastion",
    "linux"
  ]
}
```

Then add `module.terraform-module-bastion-linux.repository.name` to the repositories dict inside the core-team module definition, for example

```
module "core-team" {
  ...
  repositories = [
    ...
    module.terraform-module-bastion-linux.repository.name,
    ...
  ]
...
}
```

Once the PR is merged, terraform will create the repository https://github.com/ministryofjustice/modernisation-platform-terraform-bastion-linux

Since the new repository you're creating is for a terraform module, please also consider adding the following:

1. GitHub job for linting, refer for example to [terraform-static-analysis.yml](https://github.com/ministryofjustice/modernisation-platform-terraform-ecs/blob/main/.github/workflows/terraform-static-analysis.yml)
2. GitHub job for documentation, refer for example to [documentation.yml](https://github.com/ministryofjustice/modernisation-platform-terraform-ecs/blob/main/.github/workflows/documentation.yml)

Note the [template-repository](https://github.com/ministryofjustice/template-repository) holds all the files that will be added to every new repository.

# Modernisation Platform - GitHub

This directory creates and maintains the following GitHub items for the Modernisation Platform:

- repositories
- team membership
- team access to repositories
- rotation of `testing-ci` AWS keys and updates to corresponding [Github secrets](testing-ci.tf)

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

Once the PR is merged, terraform will create the repository <https://github.com/ministryofjustice/modernisation-platform-terraform-bastion-linux>

Since the new repository you're creating is for a terraform module, please also consider adding the following:

1. GitHub job for linting, refer for example to [terraform-static-analysis.yml](https://github.com/ministryofjustice/modernisation-platform-terraform-ecs/blob/main/.github/workflows/terraform-static-analysis.yml)
2. GitHub job for documentation, refer for example to [documentation.yml](https://github.com/ministryofjustice/modernisation-platform-terraform-ecs/blob/main/.github/workflows/documentation.yml)

Note the [template-repository](https://github.com/ministryofjustice/template-repository) holds all the files that will be added to every new repository.

## How to archive a repository
In a browser, navigate to the target GitHub repository's settings and manually archive it.

Once manually archived, delete its references in code:
1. Remove the repository module reference in [modernisation-platform/terraform/github/repositories.tf](https://github.com/ministryofjustice/modernisation-platform/blob/main/terraform/github/repositories.tf)
2. Remove the repository reference from the core team's repository list in [modernisation-platform/terraform/github/teams.tf](https://github.com/ministryofjustice/modernisation-platform/blob/be29e5e601e39749c8d3acc784e8dbdea2d2db1c/terraform/github/teams.tf#L2)

You can run a local plan in `modernisation-platform/terraform/github/` to verify the correctness of changes. You will need to pass your GH token when prompted.

Once happy with the changes, create a PR, get a review and merge your code.  Because `archive_on_destroy` is set to `true` in the [`github_repository`](https://github.com/ministryofjustice/modernisation-platform/blob/be29e5e601e39749c8d3acc784e8dbdea2d2db1c/terraform/github/modules/repository/main.tf#L24) resource it will [archive](https://github.com/integrations/terraform-provider-github/blob/2881a2a4c19475ca8a9f0b4ea6570dda4fd12b71/github/resource_github_repository.go#L857) the repository, rather than delete it, even though it will be deleted from the terraform code.
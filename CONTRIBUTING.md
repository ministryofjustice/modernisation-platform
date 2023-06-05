# Contribution guidelines

When contributing to this repository, please first discuss the change you wish to make via issue, slack, or any other method with the owners of this repository before making a change.

Our primary slack channel for contributors who wish to get in touch is #ask-modernisation-platform.

## Contributing

If you’ve got an idea or suggestion you can:

- [Contact the Modernisation Platform team](https://mojdt.slack.com/archives/C01A7QK5VM1)
- [Create a GitHub issue](https://github.com/ministryofjustice/modernisation-platform/issues)

## Raising bugs

When raising bugs, please explain the issue in reasonable detail and provide a guide on how to replicate it.

When describing the bug, it's useful to follow the format:

- What you did
- What you expected to happen
- What happened

We have a [standard template](https://github.com/ministryofjustice/modernisation-platform/issues/new?assignees=&labels=bug&projects=&template=bug-template.md) for raising bugs.

## Suggesting features

Please [raise feature requests as issues](https://github.com/ministryofjustice/modernisation-platform/issues/new?assignees=&labels=&projects=&template=story-template.md) before contributing any code.

Raising an issue ensures they are openly discussed and before spending any time on them.

## Security vulnerabilities

Please contact us through [Slack](https://mojdt.slack.com/archives/C01A7QK5VM1) to discuss the vulnerability first, before [raising an issue](https://github.com/ministryofjustice/modernisation-platform/security/advisories/new).

## Contributing code

### Terraform Versions

We use Hashicorp [Terraform](https://www.terraform.io/) to deliver Infrastructure-as-Code.

We stay up-to-date with the latest versions of Terraform, but with Terraform Providers the Modernisation Platform Team control the version in use.

### Tests

Our versioned Terraform modules have unit tests; these are written using [Terratest](https://pkg.go.dev/github.com/gruntwork-io/terratest#section-readme) and Google Go.

Your branch should ensure that changes you have made are reflected in the tests, and that these unit tests pass before raising a Pull Request.

A GitHub Action will automatically run tests against your Pull Request once you have raised it.

### Versioning

Where appropriate, versioning is based on your commit messages by using [Semantic Versioning](https://semver.org/).

Our [Modernisation Platform](https://github.com/ministryofjustice/modernisation-platform/) and [Modernisation Platform Environments](https://github.com/ministryofjustice/modernisation-platform-environments/) repositories are deployed with CI/CD from the _main_ branch, and thus are not versioned.

Terraform modules which are used by the [Modernisation Platform](https://github.com/ministryofjustice/modernisation-platform/) and [Modernisation Platform Environments](https://github.com/ministryofjustice/modernisation-platform-environments/) repositories
are versioned using GitHub Tags and Releases following Semantic Versioning.

When you come to raise a pull request, please explain the context for your pull request so that your changes are easier to understand.

### Release

Releases are actioned by the Modernisation Platform team.



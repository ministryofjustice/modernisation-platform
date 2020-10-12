# Modernisation Platform Infrastructure

This `terraform` folder contains the infrastructure as code to recreate and administer the Modernisation Platform.

## Contents

- [environments](environments) contains files for infrastructure to create environments, and configure baselines within them, such as the Ministry of Justice [Security Guidance](https://ministryofjustice.github.io/security-guidance/baseline-aws-accounts/#baseline-for-amazon-web-services-accounts) baselines
- [global-resources](global-resources) contains files for infrastructure, such as S3 buckets, that aren't part of a specific platform environment, administered at a global level

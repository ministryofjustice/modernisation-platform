# Modernisation Platform - Architecture Decisions

This is our architecture decision log, made during the design and build of the Modernisation Platform.

## Table of contents

1. ✅ [Record architecture decisions](0001-record-architecture-decisions.md)
1. ❌ [Use IAM Federated Access](0002-use-iam-federated-access.md)
1. ✅ [Use AWS SSO](0003-use-aws-sso.md)
1. ⌛️ [Use `bash`, `nodejs`, and `python` as core languages](0004-use-bash-node-python-as-core-languages.md)
1. ✅ [Use GitHub Actions as our CI/CD runner](0005-use-github-actions.md)
1. ✅ [Use a multi-account strategy for applications](0006-use-a-multi-account-strategy-for-applications.md)
1. ✅ [Use Terratest, OPA and Go for testing](0007-use-terratest-opa-and-go-for-testing.md)
1. ✅ [Use KMS in the Shared Services Account for Cross Account Encryption](0008-use-kms-in-shared-services-for-cross-account-encryption.md)
1. ✅ [Use Secrets Manager for Secrets](0009-use-secrets-manager-for-secrets.md)
1. ✅ [Terraform module strategy](0010-terraform-module-strategy.md)
1. ❌ [Use VPC flow logs to gain insight into network state](0011-use-vpc-flow-logs-to-gain-insight-into-network-state.md)
1. ❌ [Use Transit Gateway Route Analyzer to check desired state for route tables](0012-use-tgw-route-analyzer-to-check-desired-state-for-route-tables.md)
1. ❌ [Use IaC Network tester to test connectivity rules](0013-use-iac-network-tester-to-test-connectivity-rules.md)
1. ✅ [Create Application Elastic Container Repositories (ECR) in the shared-services account](0014-create-ecr-in-the-shared-services-account.md)
1. ✅ [Use AWS image builder for managing AMIs](0015-use-aws-image-builder-for-managing-amis.md)
1. ✅ [IP Address Allocation](0016-ip-address-range-allocation.md)
1. ✅ [Monitoring and Alerting](0017-monitoring-and-alerting.md)
1. ✅ [Use AWS Shield Advanced](0018-use-aws-shield-advanced.md)
1. ✅ [Use `bash` and `go` as core languages](0019-use-bash-go-as-core-languages.md)
1. ✅ [How we create and maintain documentation](0020-how-we-create-and-maintain-documentation.md)
1. ✅ [Use a Go Lambda for instance scheduling](0021-use-a-go-lambda-for-instance-scheduling.md)
1. ✅ [Patching Strategy](0022-patching-strategy.md)
1. ✅ [Backup Strategy](0023-backup-strategy.md)
1. ✅ [Egress firewall inspection](0024-egress-traffic-inspection.md)
1. ⌛ [Non Standard User Infrastructure](0025-non-standard-user-infrastructure.md)
1. ✅ [Use Network Services account for DNS resources](0026-use-network-services-account-for-dns.md)
1. ✅ [Use Member CICD Access for Configuration Management](0027-use-member-cicd-access-for-configuration-management.md)
1. ✅ [Expand the scope of the platform](0028-expand-the-scope-of-the-platform.md)
1. ♻ [How we deploy shared Active Directory controllers](0029-how-we-deploy-shared-active-directory-controllers.md)
1. ✅ [Cross environment network access](0030-cross-environment-network-access.md)
1. ✅ [LLMs will be hosted on the Analytical Platform](0031-llms-will-be-hosted-on-the-analytical-platform.md)
1. ✅ [NCSC PDNS will not be applied at platform level](0032-ncsc-pdns-not-at-platform-level.md)
1. ❌ [Increase security of sensitive S3 objects (state bucket)](0033-s3-state-bucket-condition-security.md)
1. ❌ [Use of AWS Cloud Map](0034-use-cloud-map.md)
1. ✅ [Use of Terraform Workspaces](0035-terraform-workspaces.md)
1. ✅ [Use of Component Isolation](0036-managing-environment-collaboration-with-component-isolation.md)
1. ✅ [Permissions to manage Unwanted EBS Volumes](0037-give-teams-the-permissions-to-manage-unwanted-volumes.md)
1. ✅ [Stop storing binaries and archives in git](0038-stop-storing-binaries-and-archives-in-git.md)
1. ✅ [AWS CloudTrail Multi-Region and Organization Trail Implementation](0039-cloudtrail-multi-region-org-trail.md)
1. ✅ [Transit Gateway Auto-Accept VPC Attachment Requests](0040-transit-gateway-auto-accept.md)
1. 🤔 [Adopting Entra ID](0041-adopting-entra-id.md)
1. ✅ [Monitor Object Access Without S3 Server Access Logging](0042-server-access-logging.md)
1. 🤔 [Enforce S3 KMS Encryption with SCP Guardrails](0043-enforce-s3-kms-encryption-with-scp-guardrails.md)

## Statuses

- ✅ Accepted
- ❌ Rejected
- 🤔 Proposed
- ⌛️ Superseded
- ♻️ Amended

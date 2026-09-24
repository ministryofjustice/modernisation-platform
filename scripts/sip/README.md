# AWS SIP delivery POC

This directory defines the repeatable assessment and ownership-routing contract for the AWS SIP delivery POC in [issue #13592](https://github.com/ministryofjustice/modernisation-platform/issues/13592).

It does not deploy AWS resources or replace the Terraform state and delivery workflows in existing owning repositories.

## Process

1. Run the AWS SIP implementation agent with one issue URL.
2. Record the result using `ticket-schema.yaml`.
3. Validate the assessment structure:

   ```bash
   scripts/sip/validate-assessment.sh path/to/assessment.yaml
   ```

   The validator uses Ruby's standard YAML library and checks every required field declared in `ticket-schema.yaml`.

4. Review unresolved decisions and AWS evidence requirements.
5. Implement each change in the repository selected by `ownership.yaml`.
6. Run repository-native tests and an approved development/test Terraform plan.
7. Record runtime evidence before claiming the ticket is verified or complete.

## Boundaries

- Discovery is read-only by default.
- The POC does not run Terraform applies.
- Fleet-wide controls default to disabled.
- Root-account policies start unattached and require an isolated test target.
- A human reviewer approves every proposed change and rollout expansion.

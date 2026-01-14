# Change Request: Move GitHub Terraform to dedicated repository

- **Date:** 5 January 2026
- **Owner:** Modernisation Platform
- **Summary:** Decouple and migrate all GitHub management Terraform code from the `modernisation-platform` repository into a new dedicated repository `modernisation-platform-github` to improve separation of concerns, release cadence, and governance. This enhances security by moving the code to an internal private repository rather than the public `modernisation-platform` repository.

## Scope

- Move the `terraform/github` folder (GitHub management Terraform) from `modernisation-platform` into `modernisation-platform-github`.
- Remove the GitHub-related Terraform, workflows, and references from `modernisation-platform` (leaving application/account infra intact).
- Preserve Terraform state and resource continuity (no resource recreation), maintaining existing provider configuration and secrets.

## Related Pull Requests

- Create and initialise dedicated repo: https://github.com/ministryofjustice/modernisation-platform-github/pull/2
- Start removing GitHub references from `modernisation-platform`: https://github.com/ministryofjustice/modernisation-platform/pull/11940

## Change Description

- Extract GitHub management Terraform (providers, modules, variables, workflows) from `modernisation-platform` into `modernisation-platform-github`.
- Retain the same Terraform backend and state; no state transfer is required.
- Update CI/CD (GitHub Actions) to run plans/applies from the new repository.
- Remove (or archive) GitHub-related code and workflows from `modernisation-platform`.

## Plan of Action

Stage 1 — Stand up plan-only in modernisation-platform-github

1. Freeze and align
   - Tag current `modernisation-platform` main (e.g., `github-mgmt-pre-migration-2025-12-17`).
   - Identify all GitHub Terraform code, modules, and workflows to move.

2. Enable plan-only in new repository
   - Merge `modernisation-platform-github` PR #2 (plan-only workflow; apply intentionally disabled).
   - Ensure repository secrets/provider config are in place for planning.
   - Run `terraform plan` via the new workflow and confirm zero drift.

3. Backend/state
   - Use the same Terraform backend and key as the existing setup; no state transfer required.

Pre-stage 2 preparation (before merging PR #11940)

3. Prepare apply enablement and collaborators sync in new repo
   - Open a new PR in `modernisation-platform-github` to:
     - Add a protected `apply` job (e.g., manual approval/environment protections).
     - Add/update the collaborators file with content migrated from `modernisation-platform`.
     - Confirm RBAC/secrets and branch protections meet governance requirements.
   - Keep this PR ready to merge immediately after Stage 2 starts.

4. Add safety guardrails prior to enabling apply
   - State integrity: Confirm S3 backend has versioning enabled and DynamoDB state locking is active.
   - Destruction gate: Use `terraform plan -out=tfplan` and parse `terraform show -json tfplan` to block any plans with deletions (fail the job if any `delete` actions are present).
   - Critical resource protection: Consider `lifecycle { prevent_destroy = true }` on high-value resources (e.g., core org/repo objects) during cutover.
   - Backup metadata: Export org/repo settings (repos, collaborators, teams, branch protection, secrets, webhooks) to JSON and perform full mirror clones of MP-owned repos.

5. Perform full mirror clones of MP-owned repositories
   - Create an authoritative list of MP-managed repositories (e.g., `managed_repos.txt`, one `owner/name` per line).
   - Run a mirror backup to a secure location so refs, tags, and branches can be restored:

```bash
set -euo pipefail
BACKUP_DIR="/secure/backup/github-mp-$(date +%F)"
mkdir -p "$BACKUP_DIR"

while IFS= read -r repo; do
  [[ -z "$repo" || "$repo" =~ ^# ]] && continue
  target="$BACKUP_DIR/${repo//\//__}.git"
  if [[ -d "$target" ]]; then
    git -C "$target" remote update --prune
  else
    git clone --mirror "https://github.com/$repo.git" "$target"
  fi
done < managed_repos.txt
```

   - Store backups with appropriate access controls; optionally encrypt at rest.

Stage 2 — Cut over and decommission old definitions

4. Remove old workflows and Terraform from modernisation-platform
   - Merge `modernisation-platform` PR #11940 to remove GitHub Terraform and related workflows.

5. Enable apply in the new repository
   - Merge the follow-up PR in `modernisation-platform-github` to enable `apply` and collaborators management.
   - Run a controlled first apply (expect no changes) and verify success.

6. Clean-up and documentation
   - Update docs/READMEs to point to `modernisation-platform-github` as the system of record.

7. Monitor
   - Monitor workflows and GitHub resources for 24–48 hours; capture any follow-ups.

## Impact, Guardrails & Recovery

Potential impact if an apply misbehaves (e.g., mass deletions):
- Deletion or misconfiguration of repositories, teams, collaborators, branch protections, secrets, or webhooks.

Potential Guardrails to mitigate before Stage 2:
- Block destructive plans: Use JSON plan parsing to detect and fail on any `delete` actions.
- Manual approvals: Enforce environment protection with at least two approvers; applies only from `main`.
- Backend safety: Ensure S3 state versioning and DynamoDB locks are enabled to protect state integrity.
- Scoped rollout: Use `-target` to limit initial applies; expand scope gradually.
- Prevent destroy: Temporarily add `prevent_destroy` on critical resources during cutover.
- Backups: Export org/repo metadata (repos, teams, collaborators, branch protection, secrets, webhooks) and perform full `--mirror` clones of all MP-owned repos to a secure backup location (enables push-back to recreated repositories).

If a destructive apply occurs:
1. Contain
   - Immediately cancel the workflow and disable the apply job in `modernisation-platform-github`.
   - Lock Terraform state by pausing further runs; verify backend integrity.
2. Restore repositories and core objects
   - Restore deleted repositories via GitHub org settings if available within retention windows; otherwise, recreate and push from mirror backups:

```bash
# Example: recreate and push a mirrored backup
REPO="ministryofjustice/example-repo"
BACKUP_DIR="/secure/backup/github-mp-YYYY-MM-DD"
MIRROR_PATH="$BACKUP_DIR/${REPO//\//__}.git"

# Recreate the repository (requires appropriate permissions)
# gh repo create "$REPO" --private --confirm

# Push all refs back to the new remote
git -C "$MIRROR_PATH" remote set-url origin "git@github.com:$REPO.git"
git -C "$MIRROR_PATH" push --mirror
```

   - Recreate critical teams and reapply branch protection and secrets using the exported JSON.
3. Reconcile with Terraform
   - Check out the last known-good commit (pre-Stage 2) and run `terraform plan`.
   - For existing but unmanaged objects, use `terraform import` (e.g., `github_repository`, `github_team`, `github_team_membership`, `github_branch_protection`) to rebind state, then `apply`.
   - Expand scope cautiously; continue blocking deletes until parity is confirmed.
4. Communicate
   - Notify stakeholders; document root cause and follow-ups.

## Rollback Plan

If issues arise after migration:

1. Re-enable old pipeline
   - Revert PR #11940 (or follow-up clean-up PRs) to restore GitHub Terraform and workflows in `modernisation-platform`.

```zsh
# In modernisation-platform
git checkout main
git pull --ff-only
# Identify the merge commit for PR #11940
git revert <merge_commit_sha>
git push
```

2. Disable new repository workflows
   - Temporarily disable or guard workflows in `modernisation-platform-github` until fixes are applied.

3. Communicate
   - Inform stakeholders of rollback and next steps.

## Validation & Test

Stage 1
- `terraform plan` in `modernisation-platform-github` runs successfully (no drift).
- Secrets/provider config valid; workflows execute as expected in plan-only mode.

Stage 2
- Old workflows in `modernisation-platform` are no longer active.
- First controlled `apply` in `modernisation-platform-github` completes successfully (expect no-op).
- Documentation updated; ownership and boundaries clear.
- Destruction guard passes: JSON plan check confirms zero `delete` actions before any apply.

## Risks & Mitigations

- **State drift or loss:** Prefer keeping the same backend/key; if moving, use `state pull/push` and validate plans.
- **Secret/config mismatch:** Audit provider config and repository secrets; test on a non-production workspace first.
- **Workflow race conditions:** Disable old workflows before enabling new ones; sequence cutover carefully.
- **Documentation/scoping gaps:** Update READMEs and ownership; set clear boundaries for responsibilities.

## Backout Window

- Recommended monitoring window: 24–48 hours.
- Rollback can be executed via PR revert with no data loss.

## Approvals
- [ ] Platform Engineering approval
- [ ] Application Owner / Team Lead approval
- [ ] Security approval (if trust policy scope changes)

- Platform Engineering
- Application Owner / Team Lead
- Security (if trust policy changes are material)

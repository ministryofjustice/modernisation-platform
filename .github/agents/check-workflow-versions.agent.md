---
description:
  Agent to check GitHub Actions workflow files in this repository for outdated action versions and optionally raise a PR to update them.

tools: ['runCommands', 'edit', 'search', 'fetch']
---

# Workflow Version Checker Agent

## Description

This agent scans GitHub Actions workflow files in this repository, extracts every `uses:` action reference, checks the latest release of each action on GitHub, and reports which ones are outdated.

It can target **all workflows** or a **single named workflow file**. It can also optionally update outdated versions and raise a pull request.

---

## Target Workflows

The user may optionally specify a target when invoking the agent:

- **All workflows (default)**: no target specified, or phrases like "check all workflows"
- **Single workflow**: user specifies a filename or partial name, e.g.:
  - `"check terraform-static-analysis.yml"`
  - `"check the scorecards workflow"`
  - `"update actions in deploy.yml"`

When a single workflow is specified, all scanning, reporting, and updating applies only to that file.

---

## Behaviour Overview

The agent operates in two phases:

1. **Report Phase (default)** — Scans the target workflow(s), compares versions, and outputs a summary table. No files are changed.
2. **Update Phase (opt-in)** — Only when the user explicitly asks to apply updates, the agent edits the workflow files and raises a PR.

---

## Instructions

### 1. Find Target Workflow File(s)

If the user specified a single workflow, locate it:

```bash
find .github/workflows -name "*<user-specified-name>*" | sort
```

If the name matches multiple files, list them and ask the user to confirm which one they meant.

If no target was specified, find all workflow files:

```bash
find .github/workflows -name "*.yml" -o -name "*.yaml" | sort
```

### 2. Extract All `uses:` Action References

For each workflow file, extract lines containing `uses:` that reference an external action (not local paths starting with `./`).

The typical format is one of:
- `uses: owner/repo@SHA # vX.Y.Z`  ← SHA-pinned with version comment (most common here)
- `uses: owner/repo@vX.Y.Z`        ← tag-pinned
- `uses: owner/repo/subpath@SHA # vX.Y.Z` ← action in subdirectory

For each reference, extract:
- **Action repo**: the `owner/repo` portion (first two path segments only — ignore subdirectories)
- **Current version**: taken from the `# vX.Y.Z` comment if present; otherwise the tag ref itself if it starts with `v`
- **Current SHA**: the pinned commit SHA if present
- **File path(s)** that reference this action

Deduplicate by action repo — track the highest version seen if multiple versions are in use.

Skip:
- Lines starting with `#` (comments)
- References to `./.github/...` (local reusable workflows)
- `uses:` lines inside comments

### 3. Check the Latest Release for Each Action

For each unique action repo, fetch the latest release tag using the GitHub CLI:

```bash
gh api repos/{owner}/{repo}/releases/latest --jq '.tag_name'
```

If no releases exist, fall back to the latest tag:

```bash
gh api repos/{owner}/{repo}/tags --jq '.[0].name'
```

If the repo is inaccessible or returns an error, mark it as **unknown** and continue.

### 4. Compare Versions

For each action, compare the current version in use against the latest release:

- Parse version strings as semantic version tuples: `v1.2.3` → `(1, 2, 3)`
- An action is **outdated** if `latest > current`
- An action is **up to date** if `latest == current`
- An action is **unknown** if the latest version could not be determined, or if no version comment exists and the ref is a SHA

For major version bumps (e.g. `v2` → `v3`), flag these clearly as they may contain breaking changes.

### 5. Report Results

Output a clear summary grouped by status:

#### Outdated Actions
```
🔴 OUTDATED  owner/repo
   Current : v1.2.3
   Latest  : v1.4.0
   Release : https://github.com/owner/repo/releases/tag/v1.4.0
   Files   : .github/workflows/foo.yml
             .github/workflows/bar.yml
```

#### Up to Date
```
✅ current   owner/repo @ v1.4.0
```

#### Unknown / SHA-only (no version comment)
```
❓ unknown   owner/repo (SHA-pinned, no version comment — latest: v2.1.0)
```

End with a summary line:
```
SUMMARY: 🔴 X outdated  ✅ Y up to date  ❓ Z unknown
```

### 6. Fetch Latest SHA for Outdated Actions (if updating)

Before making any changes, retrieve the latest commit SHA for the target release tag so the pin can be updated correctly:

```bash
gh api repos/{owner}/{repo}/git/ref/tags/{tag} --jq '.object.sha'
```

If the tag points to an annotated tag object (not a commit directly), dereference it:

```bash
gh api repos/{owner}/{repo}/git/tags/{sha} --jq '.object.sha'
```

### 7. Apply Updates (only when explicitly requested)

Only update files when the user has explicitly said something like:
- "Update the outdated actions"
- "Raise a PR with the fixes"
- "Apply the updates"

For each outdated action, in every workflow file that references it:

- Update the SHA to the latest commit SHA for the new release tag
- Update the version comment to the new version
- Example change:
  ```yaml
  # Before
  uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

  # After
  uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v6.0.3
  ```

**Important**: Only change the SHA and version comment. Do not alter any `with:`, `env:`, or other step parameters.

For major version bumps, warn the user before applying:
```
⚠️  Major version bump detected: owner/repo v2 → v3
    Please review the release notes before proceeding:
    https://github.com/owner/repo/releases/tag/v3
    Apply anyway? (yes/no)
```
Wait for explicit confirmation before applying major version changes.

### 8. Commit and Push

Create a new branch and commit the changes:

```bash
git checkout -b copilot/update-workflow-actions-$(date +%Y%m%d)
git add .github/workflows/
git commit -m ":copilot: chore(workflows): update GitHub Actions to latest versions"
git push origin copilot/update-workflow-actions-$(date +%Y%m%d)
```

### 9. Create Pull Request

Create a PR with:

- **Title**: `:copilot: chore(workflows): update GitHub Actions to latest versions` (or `:copilot: chore(workflows): update actions in {filename}` if a single file was targeted)
- **Labels**: `github-actions`, `copilot` (create labels if they don't exist)
- **Body** — include a table like:

```markdown
## GitHub Actions Version Updates

| Action | Current | Latest | Notes |
|--------|---------|--------|-------|
| [actions/checkout](https://github.com/actions/checkout) | `v6.0.2` | [`v6.0.3`](https://github.com/actions/checkout/releases/tag/v6.0.3) | |
| [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials) | `v6.1.2` | [`v6.2.0`](https://github.com/aws-actions/configure-aws-credentials/releases/tag/v6.2.0) | ⚠️ minor version bump |

### Skipped / Unknown
- `owner/repo`: SHA-pinned with no version comment — manual review recommended
```

### 10. Final Summary

After completing either phase, output:

- Total workflow files scanned
- Number of unique actions found
- Number outdated / up to date / unknown
- Branch and PR link (if updates were applied)

---

## Notes

- This agent **never modifies** files outside `.github/workflows/`
- The agent **never modifies** non-workflow files (e.g. Terraform, application code)
- Always prefer updating SHA + comment together — a SHA without a version comment is hard to audit
- For SHA-only pins with no version comment, report the latest version as a recommendation but do not auto-update (the correct SHA mapping cannot be verified without a reference)
- If `gh auth status` fails, ask the user to authenticate with `gh auth login` before continuing

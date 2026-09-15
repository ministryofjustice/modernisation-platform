# Modernisation Platform UI (POC)

A proof-of-concept web interface to replace the
[`new-environment` GitHub issue template](../.github/ISSUE_TEMPLATE/new-environment.yml).

Built with Node.js, Express, Nunjucks and the
[GOV.UK Design System](https://design-system.service.gov.uk/) via the
[`govuk-frontend`](https://www.npmjs.com/package/govuk-frontend) package.

> **Status:** experimental / proof of concept. The new-environment journey can
> dispatch a structured request to GitHub Actions, but preview mode is enabled
> by default and authentication is not yet implemented.

## Run with Docker (recommended)

```bash
cd ui
docker compose up --build
```

Then open <http://localhost:3000>.

To stop:

```bash
docker compose down
```

## Run locally without Docker

Requires Node.js 20+.

```bash
cd ui
npm install
npm start
```

Then open <http://localhost:3000>.

## Account request modes

The service defaults to `preview` mode. A submission renders a preview
confirmation and does not call GitHub or create any files.

Set these environment variables to enable workflow dispatch:

```bash
ENVIRONMENT_REQUEST_MODE=dispatch
GITHUB_TOKEN=<token with Actions write permission>
GITHUB_WORKFLOW_REF=main
SESSION_SECRET=<long random value>
```

The following values are optional:

```bash
GITHUB_OWNER=ministryofjustice
GITHUB_REPOSITORY=modernisation-platform
GITHUB_WORKFLOW=create-newenv.yml
```

The workflow must contain a `workflow_dispatch` trigger on the repository's
default branch before GitHub will accept dispatch requests. A fine-grained
personal access token can be used during development. Production should use a
short-lived GitHub App installation token supplied by a credential provider.

Do not enable dispatch mode until authentication and authorisation are in
front of the service. Dispatch mode refuses to start with either development
session-secret placeholder. The account forms also use session-backed CSRF
tokens for all POST requests.

Submissions are converted to a versioned JSON document and sent as the single
`request_json` workflow input. The workflow passes that document directly to:

```bash
python scripts/create-account.py --request request.json
```

In schema version 2, every selected environment access role includes its own
SSO group name. The same group can be reused across roles when appropriate.

The legacy issue trigger remains available during migration.

## Tests

Run the dependency-free Node test suite with:

```bash
cd ui
npm test
```

## Layout

```
ui/
├── Dockerfile
├── docker-compose.yml
├── package.json
└── src/
    ├── app.js               # Express + Nunjucks bootstrap
    ├── routes/
    │   ├── index.js         # GET/POST /new-environment, check, submit
    │   ├── mocks.js         # Non-destructive future service previews
    │   └── form-config.js   # Field lists + validation rules
    ├── services/
    │   └── environment-request.js # Request mapping + workflow dispatch
    └── views/
        ├── layout.njk       # GOV.UK page template
        ├── index.njk        # Start page
        ├── new-environment.njk
        ├── check-answers.njk
        ├── confirmation.njk
        └── error.njk
```

## Next steps

- SSO / auth in front of the service.
- Persist drafts.
- Replace development tokens with GitHub App token generation.
- Show the created workflow run and pull request status in the UI.

# Modernisation Platform UI (POC)

A proof-of-concept web interface to replace the
[`new-environment` GitHub issue template](../.github/ISSUE_TEMPLATE/new-environment.yml).

Built with Node.js, Express, Nunjucks and the
[GOV.UK Design System](https://design-system.service.gov.uk/) via the
[`govuk-frontend`](https://www.npmjs.com/package/govuk-frontend) package.

> **Status:** experimental / proof of concept. Not wired up to any downstream
> system yet — submissions currently render a confirmation page only.

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
    │   └── form-config.js   # Field lists + validation rules
    └── views/
        ├── layout.njk       # GOV.UK page template
        ├── index.njk        # Start page
        ├── new-environment.njk
        ├── check-answers.njk
        ├── confirmation.njk
        └── error.njk
```

## Next steps (out of scope for this POC)

- Submit the form to the GitHub REST API to open a `new-environment` issue,
  or open a PR against `modernisation-platform-environments`.
- SSO / auth in front of the service.
- Persist drafts.
- Automated tests.

# 4. Use `bash`, `nodejs`, and `python` as core languages

Date: 2020-11-19

## Status

⌛️ Superseded [0019](0019-use-bash-go-as-core-languages.md)

## Context

As we build the Modernisation Platform, we should define preferred languages for anything written and maintained by the Modernisation Platform team, including GitHub Actions and AWS Lambda functions.

## Decision

We have decided to use `bash`, `nodejs`, and `python` as our core languages, as they are both: three of the most popular languages by repository in the Ministry of Justice, and the team already have knowledge of these languages.

We ran a poll for what languages people already know within the team and the results were:
- 3 votes for `nodejs`
- 3 votes for `python`

We have also includes `bash` in this list to be explicit in that we should and can use it when needed.

We will leave it to each team member to decide what language is best for the problem they are trying to solve.

## Consequences

- `nodejs` and `python` have two of the fastest cold startup times for AWS Lambda, which are both at least 50% faster for a cold start compared to other AWS Lambda supported languages such as `java`, `.net2`, `go1x`
- our custom scripts are currently (as of the ADR date) all written in `nodejs` so we don't need to rewrite or transpile anything
- we may be restricting ourselves for future problems but we can revisit this ADR in the future

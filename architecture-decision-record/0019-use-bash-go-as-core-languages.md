# 19. Use `bash` and `go` as core languages

Date: 2022-06-14

## Status

✅ Accepted

## Context

As we build the Modernisation Platform, we should define preferred languages for anything written and maintained by the Modernisation Platform team, including GitHub Actions and AWS Lambda functions.

We were using `python` and `node.js`, but found we had limited skills in these languages on the team, and we were having to learn Go to use testing tools such as Terratest.

The Cloud Platform team and other MoJ teams have already switched to `go` with positive results.

## Decision

We have decided to use `bash` and `go` as our core languages.

We have also included `bash` in this list to be explicit in that we should and can use it when needed.

All new scripts, lambdas and tests should be written in `go` by default.

## Consequences

- `go` has excellent [cold + warm start times](https://filia-aleks.medium.com/aws-lambda-battle-2021-performance-comparison-for-all-languages-c1b441005fd1)
- `go` uses less [energy consumption](https://medium.com/codex/what-are-the-greenest-programming-languages-e738774b1957) than `python`
- this will help with our [choice of testing tools](0007-use-terratest-opa-and-go-for-testing.md)
- we align ourselves with the Cloud Platform and other MoJ teams using `go` and can learn from them
- our custom scripts are currently (as of the ADR date) written in various languages, we will need to do some work over time to move them to `go` for consistency
- we may be restricting ourselves for future problems but we can revisit this ADR in the future

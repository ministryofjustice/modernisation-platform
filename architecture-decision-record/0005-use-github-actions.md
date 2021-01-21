# 5. Use GitHub Actions as our CI/CD runner

Date: 2020-11-19

## Status

✅ Accepted

## Context

Before we start automating any part of the Modernisation Platform, we should define our CI/CD runner.

## Decision

We have decided to use GitHub Actions as our CI/CD runner due to the following:
- we don't have to roll our own infrastructure for it
- we get unlimited free running minutes on all of our public repositories
- it offers centralised CI/CD alongside our code storage
- it helps us meet our goal of working in the open
- other teams within Ministry of Justice are moving toward GitHub Actions themselves, so we can align ourselves

## Consequences

- We need to figure out how to ensure we don't leak secrets within a publicly available CI/CD platform

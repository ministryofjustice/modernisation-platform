# 30. LLMs will be hosted on the Analytical Platform

Date: 2024-01-27

## Status

✅ Accepted

## Context

Large Language Models (LLMs) are Artificial Intelligence (AI) algorithms which learn using large data sets. The use of these models is becoming more widespread and there have been several requests and initiatives to use them at the MoJ. The question is where should these LLMs be hosted?

## Options

### 1. Cloud Platform

#### Pros

- Models which can be containerised can be easily deployed

#### Cons

- Very large CPU usage currently puts existing cluster resources at risk
- Limited number of models can be run in containers
- No standards for implementation
- No control over what data is used

### 2. Modernisation Platform

#### Pros

- Supports all model types and services
- Models can sit with services

#### Cons

- No standards for implementation
- No control over what data is used
- No cost optimisation

### 3. Analytical Platform

#### Pros

- Standards can be set and enforced
- Better control over data
- Existing data expertise and tooling already present
- Cost can be better managed and optimised

#### Cons

- Model in different location to service

## Decision

Option 3, LLMs will be hosted in the Analytical Platform. The platform already has considerable knowledge and systems in place for dealing with large amounts of data securely. By hosting LLMs in the Analytical Platform MoJ users will be able to test their LLM assumptions and build production ready services in a safe environment.

## Consequences

- The Analytical Platform will build a new LLM sandbox area to allow MoJ users to start experimenting with LLMs
- The Analytical Platform will build a new production LLM service
- The Modernisation Platform team will support the Analytical Platform with any new hosting needs required

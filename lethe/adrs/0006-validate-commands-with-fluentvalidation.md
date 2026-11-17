# 0006. Validate commands with FluentValidation

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-05-14

## Status

Accepted

## Decision Outcome

Lethe API validates every command with FluentValidation and Wolverine middleware.

## Context

Validation rules were scattered across controllers.

## Decision Drivers

- Single place for rules
- Testability
- Readable errors

## Considered Options

### Option A: Data annotations
Limited.

### Option B: FluentValidation (chosen)
Composable rules.

## Decision Rationale

Rules become unit-testable code.

## Consequences

One more dependency in the pipeline.

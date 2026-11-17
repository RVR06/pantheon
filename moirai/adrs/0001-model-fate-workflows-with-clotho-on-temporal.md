# 0001. Model fate workflows with Clotho on Temporal

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-02-02

## Status

Accepted

## Decision Outcome

Clotho runs long-lived business workflows as Temporal workflows written in .NET.

## Context

Workflows last days, need retries, compensation and visibility; hand-written state machines were error prone.

## Decision Drivers

- Durable execution
- Visibility of running workflows
- Code-first definitions

## Considered Options

### Option A: Custom state machines
Fragile.

### Option B: Temporal (chosen)
Durable execution.

### Option C: Airflow
Designed for data DAGs, not business workflows.

## Decision Rationale

Temporal removes a class of bugs around retries and timers.

## Consequences

Temporal cluster operation, determinism constraints on workflow code.

# 0003. Move Ledger events to Marten on PostgreSQL

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-02-26

## Status

Accepted

## Decision Outcome

Ledger stores consent and erasure events with Marten as an event store over PostgreSQL.

## Context

The audit trail must be append-only and replayable.

## Decision Drivers

- Event sourcing
- Single database technology
- Strong consistency

## Considered Options

### Option A: Dedicated event store
Purpose-built, one more database.

### Option B: Marten on PostgreSQL (chosen)
Event store on a known engine.

## Decision Rationale

Marten gives event sourcing without a new database.

## Consequences

Projection rebuilds can be slow on large streams.

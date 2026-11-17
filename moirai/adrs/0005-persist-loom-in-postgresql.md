# 0005. Persist Loom in PostgreSQL

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-05-05

## Status

Accepted

## Decision Outcome

Loom stores workflow definitions and allocation state in PostgreSQL.

## Context

Relational integrity matters for allocations.

## Decision Drivers

- Transactions
- Known tooling
- Cost

## Considered Options

### Option A: Cosmos DB
Elastic but weaker transactions.

### Option B: PostgreSQL (chosen)
ACID.

## Decision Rationale

Allocation invariants need transactions.

## Consequences

Scaling is vertical first.

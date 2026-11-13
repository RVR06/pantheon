# 0002. Store feed items in Nectar (Cosmos DB)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-02-05

## Status

Accepted

## Decision Outcome

Persist feed items and user timelines in Nectar, an Azure Cosmos DB account with partitioning by user.

## Context

Timelines are read-heavy, document-shaped and must scale across regions.

## Decision Drivers

- Low-latency reads worldwide
- Schema flexibility
- Automatic scaling

## Considered Options

### Option A: PostgreSQL
Relational comfort, harder global distribution.

### Option B: Cosmos DB (chosen)
Global distribution and elastic throughput.

## Decision Rationale

Partition-by-user matches the access pattern; request units are predictable enough.

## Consequences

Request-unit cost needs budgeting; cross-partition queries are expensive.

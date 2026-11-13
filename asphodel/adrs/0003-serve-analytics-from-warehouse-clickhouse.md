# 0003. Serve analytics from Warehouse (ClickHouse)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-03-17

## Status

Proposed

## Decision Outcome

Use ClickHouse as Warehouse for dashboards and the API, replacing the previous row-store.

## Context

Dashboard queries over billions of rows are slow on the existing store.

## Decision Drivers

- Sub-second aggregations
- Cost efficiency
- SQL compatibility

## Considered Options

### Option A: Keep the existing store
Known, but slow.

### Option B: ClickHouse
Columnar, fast, new to the team.

## Decision Rationale

Pending a production-like benchmark and an operational plan.

## Consequences

New engine to run; update and delete semantics differ.

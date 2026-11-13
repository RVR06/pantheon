# 0002. Transform with Reaper (Apache Spark)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-01-28

## Status

Accepted

## Decision Outcome

Reaper processes Meadow into curated tables using Apache Spark, mostly Spark SQL, with PySpark for custom logic.

## Context

Volumes exceed what a single-node tool handles; analysts prefer SQL.

## Decision Drivers

- Scale-out processing
- SQL-first authoring
- Mature ecosystem

## Considered Options

### Option A: dbt on Warehouse
Simpler, limited for heavy transforms.

### Option B: Spark (chosen)
Scales and supports both SQL and code.

## Decision Rationale

Spark covers both heavy batch jobs and SQL-driven curation.

## Consequences

Cluster tuning skills required; small jobs are over-served.

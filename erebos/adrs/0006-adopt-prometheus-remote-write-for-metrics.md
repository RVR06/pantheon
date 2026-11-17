# 0006. Adopt Prometheus remote-write for metrics

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-08-12

## Status

Proposed

## Decision Outcome

Add metrics ingestion to Torch and store them in a Mimir-style backend.

## Context

Logs and traces are covered but realm metrics are still ad hoc.

## Decision Drivers

- Complete signal coverage
- Cost
- Grafana integration

## Considered Options

### Option A: Per-realm Prometheus
Fragmented.

### Option B: Central metrics
Unified.

## Decision Rationale

Under evaluation.

## Consequences

Another storage backend to operate.

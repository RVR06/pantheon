# 0003. Fan telemetry into Erebos from every realm

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-24

## Status

Accepted

## Decision Outcome

Every system exports OTLP to Torch in Erebos. Local dashboards remain allowed but Watchtower is the reference.

## Context

Operators need correlated traces across realms.

## Decision Drivers

- Cross-realm correlation
- One ingestion contract
- Cost control

## Considered Options

### Option A: Per-realm stacks
Autonomy, fragmented incidents.

### Option B: Central Erebos (chosen)
Correlation.

## Decision Rationale

Incidents span realms, so telemetry must too.

## Consequences

Erebos becomes a shared dependency with strong availability needs; Torch must stay thin.

# 0004. Visualise with Watchtower (Grafana)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-03-11

## Status

Accepted

## Decision Outcome

Watchtower is the single Grafana instance for logs, traces and metrics.

## Context

Operators switched between tools during incidents.

## Decision Drivers

- One pane of glass
- Cross-signal links
- Access control

## Considered Options

### Option A: Kibana plus others
Several tools.

### Option B: Grafana (chosen)
Unified.

## Decision Rationale

Correlation between signals is the biggest incident-time win.

## Consequences

Dashboards must be governed to avoid sprawl.

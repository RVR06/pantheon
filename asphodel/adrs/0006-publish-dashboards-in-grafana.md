# 0006. Publish Dashboards in Grafana

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-05-12

## Status

Accepted

## Decision Outcome

Dashboards is a Grafana instance reading Warehouse and Pythia API.

## Context

Business users need self-service charts; building custom UI is wasteful.

## Decision Drivers

- Self-service
- Reuse tooling known in Erebos
- Access control

## Considered Options

### Option A: Custom UI
Full control, high cost.

### Option B: Grafana (chosen)
Rich panels, familiar to ops.

## Decision Rationale

Aligns with the observability stack so skills carry over.

## Consequences

Heavy analytical dashboards need data modelling discipline.

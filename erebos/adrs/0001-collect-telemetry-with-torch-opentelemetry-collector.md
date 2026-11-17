# 0001. Collect telemetry with Torch (OpenTelemetry Collector)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-01-10

## Status

Accepted

## Decision Outcome

Every realm sends OTLP to Torch, the OpenTelemetry Collector, which routes to Shadows and Twilight.

## Context

Each team shipped telemetry differently, making cross-realm correlation impossible.

## Decision Drivers

- One ingestion contract
- Vendor neutrality
- Central sampling

## Considered Options

### Option A: Direct exports
Simple, uncontrolled.

### Option B: Collector (chosen)
Single pipeline.

## Decision Rationale

OTLP plus a collector is the lowest-friction way to unify realms.

## Consequences

Torch is critical infrastructure and must be highly available.

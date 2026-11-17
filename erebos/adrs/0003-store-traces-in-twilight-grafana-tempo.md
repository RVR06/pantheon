# 0003. Store traces in Twilight (Grafana Tempo)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-02-19

## Status

Accepted

## Decision Outcome

Twilight is Grafana Tempo with object storage.

## Context

Trace volumes make a database-backed store costly.

## Decision Drivers

- Cost-effective storage
- Grafana integration
- Scale

## Considered Options

### Option A: Jaeger with Elasticsearch
Duplicates Shadows.

### Option B: Tempo (chosen)
Object storage.

## Decision Rationale

Tempo is cheap and integrates with Watchtower.

## Consequences

Search is trace-id centric; attribute search is limited.

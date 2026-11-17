# 0002. Index logs in Shadows (Elasticsearch)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-01-25

## Status

Accepted

## Decision Outcome

Shadows stores logs in Elasticsearch with a 30 day hot retention.

## Context

Operators need full-text search over logs during incidents.

## Decision Drivers

- Fast text search
- Retention control
- Familiar tooling

## Considered Options

### Option A: Loki
Cheaper, weaker queries.

### Option B: Elasticsearch (chosen)
Full-text search.

## Decision Rationale

Incident response relies on rich queries.

## Consequences

Storage cost grows with ingestion.

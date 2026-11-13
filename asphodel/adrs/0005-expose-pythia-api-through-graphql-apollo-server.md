# 0005. Expose Pythia API through GraphQL (Apollo Server)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-04-08

## Status

Accepted

## Decision Outcome

Pythia API is a Node.js Apollo Server exposing curated data with DataLoader batching.

## Context

Consumers need flexible queries without a proliferation of REST endpoints.

## Decision Drivers

- Flexible consumer queries
- Avoid N+1 queries
- Typed schema

## Considered Options

### Option A: REST endpoints
Simple, many endpoints.

### Option B: GraphQL (chosen)
One schema, consumer-shaped queries.

## Decision Rationale

GraphQL with DataLoader keeps database round trips under control.

## Consequences

Query cost control and caching need additional design.

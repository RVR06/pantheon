# 0003. Serve search from Ambrosia Search (Elasticsearch)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-03-03

## Status

Accepted

## Decision Outcome

Ambrosia Search is an Elasticsearch index fed by a Kafka consumer; the feed API queries it for discovery.

## Context

Full-text and faceted queries do not fit Nectar.

## Decision Drivers

- Rich full-text features
- Rebuildable from Harp
- Mature tooling

## Considered Options

### Option A: Cosmos DB queries
Limited text search.

### Option B: Elasticsearch (chosen)
Best-in-class search.

### Option C: Azure AI Search
Managed but pricier and less flexible.

## Decision Rationale

Elasticsearch is already operated by another realm, which lowers the learning cost.

## Consequences

Cluster upkeep; index mappings are a shared concern with data modelling.

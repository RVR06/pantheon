# 0003. Cache plans in Ambrosia (Redis) with a short TTL

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-03-12

## Status

Accepted

## Decision Outcome

Athena Planner caches computed plans in Ambrosia with a 5 minute TTL, keyed by the request hash.

## Context

Identical plan requests arrive in bursts from Olympus Portal and Hephaestus CLI, and each one costs a full planning run.

## Decision Drivers

- Cut planning cost for repeated requests
- Keep stale data window small
- Avoid a second source of truth

## Considered Options

### Option A: No cache
Simplest, but costly under bursts.

### Option B: In-memory cache per instance
Fast but inconsistent across replicas.

### Option C: Ambrosia (Redis) shared cache (chosen)
Shared, evictable, observable.

## Decision Rationale

A shared TTL cache solves the burst problem without making Ambrosia a system of record.

## Consequences

Cache invalidation is time-based only; a plan can be up to five minutes old.

# 0004. Rate limit at the edge with System.Threading.RateLimiting

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-04-02

## Status

Accepted

## Decision Outcome

Apply token-bucket limits per client in Zeus Gateway using the built-in rate limiter middleware, state kept in Ambrosia for multi-replica consistency.

## Context

A misbehaving Hephaestus CLI script saturated Athena Planner and degraded the portal for everyone.

## Decision Drivers

- Protect Athena Planner from bursts
- No extra infrastructure
- Limits must be per client and visible

## Considered Options

### Option A: Limit inside each service
Duplicated logic and uneven behaviour.

### Option B: Built-in rate limiter in Zeus Gateway (chosen)
One place, framework-supported.

### Option C: Third-party throttling product
More features, more moving parts.

## Decision Rationale

The framework limiter is enough for our policies and keeps limits next to authentication.

## Consequences

Distributed counters add a Redis dependency to every request in the hot path.

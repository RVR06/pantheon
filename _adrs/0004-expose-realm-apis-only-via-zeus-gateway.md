# 0004. Expose realm APIs only via Zeus Gateway

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-25

## Status

Accepted

## Decision Outcome

Zeus Gateway in Olympus is the only entry point for external callers to any realm API.

## Context

Each realm secured its own public endpoints in different ways.

## Decision Drivers

- Single security posture
- Rate limiting
- Auditing

## Considered Options

### Option A: Per-realm ingress
Autonomy, inconsistent security.

### Option B: Zeus Gateway (chosen)
Uniform.

## Decision Rationale

One edge is easier to defend than many.

## Consequences

Olympus becomes a coupling point; its availability matters for everyone.

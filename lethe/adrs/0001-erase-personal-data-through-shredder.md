# 0001. Erase personal data through Shredder

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-01-15

## Status

Accepted

## Decision Outcome

All erasure requests flow through Lethe API to Shredder, which removes or crypto-shreds personal data across the realm.

## Context

GDPR erasure requests currently require manual coordination between teams.

## Decision Drivers

- Legal deadlines
- Auditable outcomes
- Single entry point

## Considered Options

### Option A: Each team erases its own data
No consistency, no audit.

### Option B: Shredder as orchestrator (chosen)
One workflow, one audit trail.

## Decision Rationale

A single orchestrator makes deadlines and evidence tractable.

## Consequences

Every system must expose an erasure contract.

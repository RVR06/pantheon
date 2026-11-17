# 0005. Route erasure requests through Lethe

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-26

## Status

Accepted

## Decision Outcome

Every realm exposes an erasure contract that Shredder in Lethe invokes. Personal data erasure is orchestrated centrally.

## Context

Compliance requires evidence of erasure across all realms.

## Decision Drivers

- Legal compliance
- Auditable evidence
- Consistent process

## Considered Options

### Option A: Each realm handles requests
No central evidence.

### Option B: Lethe orchestrates (chosen)
One audit trail.

## Decision Rationale

A single orchestrator is the only way to produce one proof of erasure.

## Consequences

Every realm owes Lethe a contract; Lethe availability affects compliance deadlines.

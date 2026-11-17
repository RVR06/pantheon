# 0002. Integrate realms through events rather than shared databases

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-23

## Status

Accepted

## Decision Outcome

Realms integrate through Hermes, Harp, River and Signal Hub style channels or HTTP through Zeus Gateway. No realm reads another realm database.

## Context

Cross-realm data access through shared databases created hidden coupling in earlier efforts.

## Decision Drivers

- Loose coupling
- Independent release cadence
- Clear ownership

## Considered Options

### Option A: Shared databases
Fast to build, couples schemas.

### Option B: Events and APIs (chosen)
Explicit contracts.

## Decision Rationale

Contracts at the boundary keep realms independently deployable.

## Consequences

More infrastructure to run; eventual consistency to design for.

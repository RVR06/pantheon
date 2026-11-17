# 0007. Let every team own its styling and icons

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-27

## Status

Accepted

## Decision Outcome

Style rules and icons belong to each system workspace; the umbrella aggregates them on import.

## Context

A shared stylesheet forced teams to negotiate every colour.

## Decision Drivers

- Team identity
- No central bottleneck
- Recognisable systems

## Considered Options

### Option A: Shared theme
Consistency, friction.

### Option B: Aggregate team styles (chosen)
Identity per team.

## Decision Rationale

Brand colours are part of how a team recognises its system on the map.

## Consequences

Tag collisions between teams must be avoided; the umbrella wins on conflicts.

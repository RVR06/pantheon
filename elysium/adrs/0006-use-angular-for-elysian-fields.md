# 0006. Use Angular for Elysian Fields

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-05-20

## Status

Deprecated

## Decision Outcome

Elysian Fields, the web client, stays on Angular but no new modules should be added.

## Context

The web client lags the mobile client and the team wants to converge on a single UI approach.

## Decision Drivers

- Reduce frameworks
- Reuse mobile design system
- Protect existing investment

## Considered Options

### Option A: Keep Angular for all work
Status quo.

### Option B: Freeze Angular, plan consolidation (chosen)
No new modules while a path is chosen.

## Decision Rationale

Freeze avoids sinking cost into a framework likely to be retired.

## Consequences

Maintenance mode for Elysian Fields until a replacement is decided.

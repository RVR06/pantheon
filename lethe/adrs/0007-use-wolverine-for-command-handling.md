# 0007. Use Wolverine for command handling

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-08-25

## Status

Proposed

## Decision Outcome

Introduce Wolverine as the message and command bus in Lethe API.

## Context

Hand-written handlers and outbox code are repetitive.

## Decision Drivers

- Less boilerplate
- Transactional outbox
- Works with Marten

## Considered Options

### Option A: Keep custom handlers
Known code, more upkeep.

### Option B: Wolverine
Integrated with Marten and NATS.

## Decision Rationale

Pending a spike on observability integration.

## Consequences

Learning curve and dependency on a young library.

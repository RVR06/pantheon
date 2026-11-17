# 0008. Allow realms to read each other through shared caches

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-29

## Status

Rejected

## Decision Outcome

Do not allow a realm to read another realm cache such as Ambrosia directly.

## Context

A shortcut was proposed to let Elysium read Olympus plan caches.

## Decision Drivers

- Speed
- Coupling
- Ownership

## Considered Options

### Option A: Direct cache read
Fast, couples internals.

### Option B: Use published APIs (chosen)
Explicit.

## Decision Rationale

Caches are internal; consumers must use the contract.

## Consequences

Slightly higher latency for the occasional cross-realm read.

# 0005. Write Audit CLI in Rust

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-04-21

## Status

Accepted

## Decision Outcome

Audit CLI is a Rust binary used by auditors to verify erasure evidence offline.

## Context

Auditors need a single static binary with predictable behaviour on locked-down machines.

## Decision Drivers

- Static binary
- Memory safety
- Cross-platform

## Considered Options

### Option A: Go
Also static, already used in Lethe for Shredder.

### Option B: Rust (chosen)
Safety and tiny binary.

## Decision Rationale

Rust was chosen for its guarantees; the team accepts the learning curve.

## Consequences

Few maintainers; hiring is harder than for Go or C#.

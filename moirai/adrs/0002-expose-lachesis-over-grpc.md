# 0002. Expose Lachesis over gRPC

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-02-24

## Status

Accepted

## Decision Outcome

Lachesis, the allocation service, is a .NET gRPC service consumed by Clotho and Spindle Console.

## Context

High-frequency calls and strict contracts between internal services.

## Decision Drivers

- Strict contracts
- Low overhead
- Streaming

## Considered Options

### Option A: REST
Ubiquitous, looser contracts.

### Option B: gRPC (chosen)
Typed, efficient.

## Decision Rationale

Protobuf contracts make breaking changes visible.

## Consequences

Browsers need a gRPC-Web proxy.

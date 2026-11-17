# 0008. Server-render the Consent Console

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-06-02

## Status

Rejected

## Decision Outcome

Consent Console remains a Blazor WebAssembly client.

## Context

A proposal wanted server-rendered pages to simplify security reviews.

## Decision Drivers

- Attack surface
- Offline resilience
- Skills

## Considered Options

### Option A: Blazor Server
Simpler trust boundary, persistent connection.

### Option B: Blazor WebAssembly (chosen)
Static hosting, no circuits.

## Decision Rationale

Static hosting keeps the console available even when the API is degraded.

## Consequences

Larger initial download.

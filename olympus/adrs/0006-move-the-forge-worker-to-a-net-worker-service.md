# 0006. Move the Forge Worker to a .NET Worker Service

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-06-09

## Status

Accepted

## Decision Outcome

Rewrite the Forge Worker as a .NET Worker Service, superseding ADR-0005. Hephaestus CLI stays in Go.

## Context

Duplicating token validation, telemetry and the Hermes client in Go cost more than the start-up gain.

## Decision Drivers

- Reuse shared .NET libraries
- One telemetry pipeline
- Keep Go where it shines: the CLI

## Considered Options

### Option A: Stay in Go
Requires duplicating shared libraries.

### Option B: .NET Worker Service (chosen)
Reuses everything, hosted-service lifecycle.

## Decision Rationale

Operational consistency outweighs the start-up gain; the Forge Worker is a long-lived service anyway.

## Consequences

Container image is larger; the Go skills remain useful only for Hephaestus CLI.

# 0005. Write the Forge Worker in Go

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-04-20

## Status

Superseded by ADR-0006

## Decision Outcome

Implement the Forge Worker as a Go service.

## Context

The first Forge Worker prototype was written in Go for fast start-up, while the rest of Olympus is .NET.

## Decision Drivers

- Fast cold start
- Small container footprint
- Skills available in the team

## Considered Options

### Option A: Go (chosen at the time)
Small and fast, but a third language in the realm.

### Option B: .NET Worker Service
Shared libraries and tooling.

## Decision Rationale

Go looked attractive for start-up cost.

## Consequences

Shared auth and telemetry code had to be duplicated, which led to ADR-0006.

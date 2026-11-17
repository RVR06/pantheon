# 0008. Adopt Python for Athena Planner experiments

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-10

## Status

Proposed

## Decision Outcome

Allow Athena Planner to host experimental optimisers written in Python/FastAPI behind the existing contract.

## Context

Researchers want to ship solver prototypes without a C# rewrite.

## Decision Drivers

- Shorter path from notebook to service
- Keep the contract stable
- Contain blast radius

## Considered Options

### Option A: Python/FastAPI sidecar
Fast iteration, separate deployment.

### Option B: Port everything to .NET
Consistent but slow for research.

## Decision Rationale

Pending a spike on latency and packaging.

## Consequences

Adds a language and a container to operate if accepted.

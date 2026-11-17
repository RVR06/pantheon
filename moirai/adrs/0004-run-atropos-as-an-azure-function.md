# 0004. Run Atropos as an Azure Function

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-04-17

## Status

Accepted

## Decision Outcome

Atropos, which terminates workflows, is an Azure Function triggered from Signal Hub.

## Context

Termination is bursty and short-lived.

## Decision Drivers

- Pay per use
- Scale to zero
- Simple deployment

## Considered Options

### Option A: Always-on worker
Idle cost.

### Option B: Azure Function (chosen)
Serverless.

## Decision Rationale

Usage pattern matches consumption pricing.

## Consequences

Cold starts and a different local development story.

# 0001. Front every realm API with Zeus Gateway

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-02-04

## Status

Accepted

## Decision Outcome

Expose every back-end API of the pantheon through Zeus Gateway (YARP). No service is reachable from outside except via Zeus Gateway.

## Context

Olympus Portal and Hephaestus CLI started calling services directly, each with its own CORS, token and retry handling. Teams added endpoints without any central view of what was public.

## Decision Drivers

- One public surface to secure and monitor
- Consistent authentication and rate limits
- Teams must keep release independence

## Considered Options

### Option A: Direct calls
Every client talks to every service. Simple, but the public surface grows with each team.

### Option B: Zeus Gateway on YARP (chosen)
Reverse proxy with routes declared per service.

### Option C: Managed API gateway
Offloads operations but adds cost and vendor coupling.

## Decision Rationale

YARP is a library on the stack the team already runs, so routing stays in code review and deploys with the rest of Olympus.

## Consequences

One more hop on every call; Zeus Gateway becomes a critical path that needs its own redundancy and dashboards.

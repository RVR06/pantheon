# 0007. Server-side render Olympus Portal

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-07-01

## Status

Rejected

## Decision Outcome

Do not move Olympus Portal to server-side rendering. Keep the React single-page application.

## Context

A proposal suggested server rendering the portal for faster first paint.

## Decision Drivers

- First paint on slow networks
- Operational simplicity
- Existing React investment

## Considered Options

### Option A: Next.js server rendering
Better first paint but adds a Node runtime to operate.

### Option B: Keep the SPA (chosen)
Static hosting behind Zeus Gateway.

## Decision Rationale

The portal is used by authenticated staff on fast networks; the gain does not justify a new runtime.

## Consequences

First paint stays heavier; revisit if external audiences appear.

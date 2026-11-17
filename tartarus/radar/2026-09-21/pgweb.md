---
title: "pgweb"
ring: "assess"
quadrant: "platforms-and-operations"
tags: [database, devex]
---

pgweb is a lightweight, open-source, browser-based PostgreSQL database browser — a single static binary exposing a web UI for running queries and inspecting tables without a full desktop client.

We picked it for the Tartarus spike (personified as Anamnesis) as the ad-hoc inspection tool for the Postgres-backed circles-of-hell table, wired via Aspire's `.WithPgWeb()` convenience method on the Postgres resource builder.

## Context

Once the Underworld's reference data moved into Postgres (see the PostgreSQL entry and [ADR-0002](../../../_archi/adrs/0002-persist-underworld-circles-in-postgres-via-shared-underworldatlas.md)), a quick way to eyeball the seeded rows during development was needed without reaching for `psql` or a heavier desktop client. Aspire's Postgres hosting integration exposes `WithPgWeb()` as a one-line addition, mirroring the same "browser-based inspection UI alongside the broker/database" convenience already used for RabbitMQ's management plugin.

## Assessment

pgweb has no production-scale concerns here since it's purely a development-time inspection tool, not a runtime dependency of the spike itself. Its main value in this spike was zero-config availability via the Aspire integration — no separate container image choice or wiring was needed beyond one method call. No comparison against alternatives (Adminer, DBeaver, psql) was performed, since the Aspire-native option was an obvious low-risk default.

## Recommendation

The pattern sits in assess: it did its job well as a convenience tool in this spike, but hasn't yet been exercised against a non-trivial schema, so no reuse recommendation beyond "small spike, ad-hoc inspection" scope is warranted yet.

## Next Steps

- Try it against a spike with a larger/more relational schema to see if its query/browsing UX still holds up
- No further action needed for spike-scale, ad-hoc inspection use cases

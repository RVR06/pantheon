---
title: "PostgreSQL"
ring: "trial"
quadrant: "staples"
tags: [database]
---

PostgreSQL is a mature, open-source relational database with strong ACID guarantees, broad tooling support, and a first-class Aspire hosting integration.

We picked it for the Tartarus spike (personified as Mnemosyne) specifically to eliminate a data-duplication problem: the same reference data (the nine circles of hell) was previously hardcoded as two separately maintained C# arrays in two different services.

## Context

Two services (Charon and Minos) each held their own copy of a small, static reference dataset, with nothing enforcing that the two copies stayed in sync. Aspire's `Aspire.Hosting.PostgreSQL` plus `Aspire.Npgsql` integrations made it straightforward to add a database resource, seed it once, and read it from both services — see [ADR-0002](../../../_archi/adrs/0002-persist-underworld-circles-in-postgres-via-shared-underworldatlas.md).

## Assessment

Postgres is an industry-standard relational database with extensive community evidence, and the Aspire integration handles connection-string wiring, health checks, and data-volume persistence with minimal code. For this spike's scope, plain `Npgsql` (no ORM/migrations) was sufficient for nine seed rows, and idempotent seeding (`CREATE TABLE IF NOT EXISTS` + `ON CONFLICT DO NOTHING`) handled the lack of a startup-order guarantee between the two consuming services cleanly.

## Recommendation

The pattern sits in trial: using Postgres purely as a shared source-of-truth for small reference data (rather than as a primary transactional store) worked well here and is a pattern worth reusing in future spikes that hit the same "duplicated hardcoded array across services" problem. A larger-scale use of Postgres (real transactional workloads, migrations, schema evolution) would need separate evaluation.

## Next Steps

- Reuse this idempotent-seed-plus-shared-reader pattern the next time a spike needs one canonical copy of small reference data
- Evaluate EF Core/migrations tooling if a future spike's data model grows beyond a handful of static tables

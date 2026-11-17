# 0009. Create the underworld database explicitly for Kubernetes

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-21

## Status

Accepted

## Decision Outcome

Set `POSTGRES_DB=underworld` as a plain environment variable on the Mnemosyne container (`.WithEnvironment("POSTGRES_DB", "underworld")`), so the stock `postgres` image's own entrypoint creates the `underworld` database itself on first start — rather than relying on `AddDatabase`'s local-run-only database-creation mechanism, which never reaches the Kubernetes publisher.

## Context

Minos crashed on startup in the Kubernetes deployment with `Npgsql.PostgresException: 3D000: database "underworld" does not exist`, even though the exact same AppHost model works correctly under `aspire run`. `mnemosyne.AddDatabase("underworld")` only wires the connection string/reference for Charon and Minos to consume — the actual `CREATE DATABASE` happens through a mechanism Aspire sets up for local container runs (an init script executed against the Postgres container), which is bind-mount-based under the hood, the same category of limitation already hit twice in ADR-0007 (Clio's `_archi` mount, Hecate's realm import). The Kubernetes publisher drops it silently instead of erroring, so the gap only surfaced at runtime, not at publish or deploy time.

## Decision Drivers

- `UnderworldAtlas.EnsureSeededAsync` (shared by Charon and Minos, see [ADR-0002](./0002-persist-underworld-circles.md)) only issues `CREATE TABLE IF NOT EXISTS`/`INSERT ... ON CONFLICT DO NOTHING` against the `underworld` database — it assumes the database itself already exists, and Npgsql can't even open a connection to a database that isn't there yet, so this fails before any application code runs.
- This spike only ever needs one database on Mnemosyne (`underworld`), so a solution scoped to "exactly one database" is acceptable — no need to solve the general multi-database case.
- Per this spike's standing convention, prefer the documented, officially-supported mechanism over inventing a Kubernetes-specific script or Dockerfile, and capture any workaround that's still needed in an ADR.

## Considered Options

### Option A: Bake a custom Postgres image with a `docker-entrypoint-initdb.d` script (same pattern as Hecate's realm Dockerfile)
Works, but duplicates the Dockerfile-plus-publish-mode-branching machinery from ADR-0007's Hecate fix for a problem that the stock Postgres image already solves on its own via a single environment variable - unnecessary extra moving parts for this spike's single-database case.

### Option B: Set `POSTGRES_DB=underworld` as a plain environment variable (chosen)
The official `postgres` Docker image documents `POSTGRES_DB` as the name of the one database it creates automatically via `initdb` on first start (empty data directory), in addition to the default `postgres` maintenance database - this is exactly the "one database per server" shape Mnemosyne has today. Being a plain environment variable (not a bind mount, not a custom image), it carries over identically to both `aspire run` and the Kubernetes publisher's generated ConfigMap - no `IsRunMode` branching needed.

### Option C: Have `UnderworldAtlas` create the database itself at startup
Would require a separate connection to Postgres's default maintenance database (`postgres`) before the app's normal `underworld`-scoped `NpgsqlDataSource` can be used at all, since Npgsql can't open a connection to a database that doesn't exist yet - meaningfully more application code for a problem the Postgres image's own entrypoint already solves declaratively.

## Decision Rationale

Option B directly uses the mechanism the Postgres image itself documents for this exact scenario, needs no custom image or extra publish-mode branch, and - because it's a plain environment variable - behaves identically whether the AppHost is run locally or published/deployed to Kubernetes. Option A works but re-solves an already-solved problem with more moving parts; Option C pushes database-creation logic into application code that the official image already handles more simply.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| `underworld` is created reliably on first Postgres start in every execution mode (run, publish, deploy), with zero extra files or publish-mode branching | This only works because Mnemosyne hosts exactly one database; a second `AddDatabase(...)` call on the same Postgres server would need a different mechanism (e.g. the Option A Dockerfile pattern) since `POSTGRES_DB` only names a single database |

## Consequences

### Positive
- Minos and Charon can both open their `underworld` connection successfully on a freshly created Kubernetes deployment, with no change to `UnderworldAtlas` or either project's startup code.
- Verified via `aspire publish`: the generated `Hades/aspire-output` chart's `mnemosyne-config` ConfigMap and `values.yaml` now carry `POSTGRES_DB: "underworld"` alongside the existing `POSTGRES_USER`/`POSTGRES_INITDB_ARGS` entries.

### Negative
- None identified - this is a documented, zero-cost use of the base image's own initialization behavior.

### Neutral
- The generated Kubernetes StatefulSet mounts Mnemosyne's data volume as `emptyDir: {}` rather than a `PersistentVolumeClaim` (unlike `WithDataVolume()`'s effect in run mode, which maps to a named Docker volume) - meaning the Postgres data directory is always empty on pod (re)start in this cluster today, so `POSTGRES_DB`'s "first start" initialization always runs. Persisting Mnemosyne's data across pod restarts in Kubernetes is a separate concern, out of scope for this decision.

## Related Decisions

- [ADR-0007](./0007-scope-kubernetes-publish-to-deployable-resources.md) — the first two bind-mount-related Kubernetes publish gaps (Clio, Hecate); this is the third, affecting Mnemosyne instead.

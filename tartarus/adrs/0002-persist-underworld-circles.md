# 0002. Persist the Underworld's circles

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-21

## Status

Accepted

## Decision Outcome

Move Dante's nine circles of hell out of two separately hardcoded C# arrays (one in Charon's `/underworld` handler, one in Minos's judgment logic) into a single Postgres table (`circles_of_hell`, in the `underworld` database on the Mnemosyne server), read by both services through a shared `UnderworldAtlas` class.

## Context

Before this change, `Charon/Program.cs` held a `CircleOfHell[]` array used to answer `GET /underworld`, and `Minos/MinosTribunal.cs` held a parallel `string[] Circles` used only for its name/count when judging arrivals. Both arrays had to be kept in sync by hand, and nothing enforced that they agreed — a classic single-source-of-truth violation that would only get worse as the Underworld's data model grows.

## Decision Drivers

- Exactly one place in the codebase may define what the nine circles are; everywhere else must read, never redeclare.
- Startup order between Charon and Minos is not guaranteed by the AppHost (Minos only `WaitFor`s the Postgres database, not Charon), so whichever service seeds the data must not assume the other has run first.
- Spike-scope: avoid introducing EF Core/migrations tooling for nine rows; stay on plain `Npgsql`.

## Considered Options

### Option A: Keep two hardcoded arrays, add a shared constants file
Extract the circle names into a shared `Chaos` constant so both projects reference the same literal C# array — reduces duplication but still isn't queryable/persistent data, and doesn't remove the underlying problem (data that should live in a database still lives in source code).

### Option B: Move circles into Postgres (Mnemosyne), read via shared `UnderworldAtlas`
Add an `Aspire.Hosting.PostgreSQL` resource ("mnemosyne"), an `underworld` database, a `circles_of_hell` table, and a shared `UnderworldAtlas` class (in `Chaos`) with `EnsureSeededAsync` (idempotent seed) and `GetCirclesAsync` (read), used by both Charon and Minos.

### Option C: Full EF Core + migrations
Same end state as Option B but modeled with an EF Core `DbContext` and migration history instead of raw SQL.

## Decision Rationale

Option B was chosen: it fully removes the duplication (one seed statement, one table, one shared read path) and satisfies the goal of storing Underworld data in a database instead of a hardcoded array, while staying at the spike's existing complexity level (plain `Npgsql`, no ORM/migrations machinery, matching Option A's simplicity budget but actually solving the duplication instead of just relocating it). Because Minos does not wait for Charon at startup, `UnderworldAtlas.EnsureSeededAsync` is deliberately idempotent (`CREATE TABLE IF NOT EXISTS` + `INSERT ... ON CONFLICT (number) DO NOTHING`) and is called defensively from both services — Charon as the intended single writer, Minos only as a safety net against the missing ordering guarantee, never overwriting existing rows.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| One canonical, queryable source of truth for the circles, shared by both services | An extra AppHost resource (Mnemosyne/Postgres) and container to run for what is still fundamentally nine static rows |
| Idempotent seeding removes any real startup-order dependency between Charon and Minos | Minos re-running `EnsureSeededAsync` on every startup is a workaround for an ordering gap, not a guarantee — a genuinely different first-writer could still race in a heavier deployment |

## Consequences

### Positive
- `GET /underworld` and Minos's judgment logic now read from the same rows; a future change to a circle's description only has to happen once.
- Postgres/Mnemosyne is now available as a first-class Aspire resource (`WithPgWeb`/Anamnesis) for ad-hoc inspection during development.

### Negative
- Seed data (the nine circles) still lives in C# as the argument to `EnsureSeededAsync` — only the runtime *read* path was de-duplicated, not the initial seed authorship. Acceptable for a spike; would need a proper migration/seed-data pipeline in a production system.

### Neutral
- Minos calling `EnsureSeededAsync` is intentionally defensive, not the "real" write path — see [ADR-0004](./0004-adopt-tech-agnostic-persona-naming.md) for the related Mnemosyne/Anamnesis naming decision.

## Related Decisions

- [ADR-0001](./0001-rely-on-rabbitmq-client-built-in-otel-instrumentation.md) — `minos.judge-soul` tags the circle read from this same Postgres-backed data.
- [ADR-0009](./0009-create-the-underworld-database-explicitly-for-kubernetes.md) — the Kubernetes-specific fix for actually creating the `underworld` database this ADR's `UnderworldAtlas` seeding logic assumes already exists.

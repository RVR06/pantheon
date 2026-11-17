# 0004. Adopt tech-agnostic persona naming

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-21

## Status

Accepted

## Decision Outcome

Name infrastructure-facing components after their *semantic role* rather than their underlying technology: the Keycloak identity provider is **Hecate**, its realm is **erebus**, the pgweb database-inspection UI is **Anamnesis**, and the shared cross-project library is **Chaos** — none of these names leak the specific product (`keycloak`, `pgweb`) or a generic label (`ServiceDefaults`) once a persona fits.

## Context

After the mythological rename in [ADR-0003](./0003-adopt-mythological-naming-taxonomy.md), two categories of names still broke the theme: infrastructure UIs whose resource/container names were literal product names (`keycloak`, `pgweb`), and the `Cerberus.ServiceDefaults` project, whose name described *what it is* (a template convention) rather than *what it means* in this spike. The realm name `underworld` also collided with the Postgres database name `underworld`, adding a second, unrelated naming problem in the same area.

## Decision Drivers

- Any name chosen must be recognizable as a role (identity gate, memory-recall UI, shared foundation) without requiring the reader to already know the underlying technology.
- The identity realm name must not collide with the Postgres database name (both were previously "underworld", confusing side-by-side in logs/config).
- The shared library name must reflect what every project depends on, without implying it's just "ASP.NET Core service defaults boilerplate" when it also carries the shared `UnderworldAtlas`/`CircleOfHell`/ `SoulArrival` domain contracts.

## Considered Options

### Option A: Keep literal technology names (`keycloak`, `pgweb`, `ServiceDefaults`)
Lowest churn, but breaks the theme for exactly the components a reader encounters first (login, DB inspection) and leaves the shared-library name generic.

### Option B: Tech-agnostic persona names surfacing semantic role
- **Hecate** — goddess of magic, crossroads, and gates ("Kleidouchos", the key-bearer) for Keycloak: she holds the keys to every realm, exactly what an identity provider does.
- **Erebus** — primordial personification of darkness/shadow, the region souls pass *through* immediately after death, before reaching the Underworld proper — the realm/auth-boundary name, distinct from the `underworld` database (the actual data domain).
- **Anamnesis** — Greek for "recollection" — the browser-based inspection UI (pgweb) that lets a developer recall/inspect what Mnemosyne remembers.
- **Chaos** — the primordial void from which everything else in the pantheon springs — the shared library every project (Hades, Charon, Cerberus, Minos) ultimately depends on.

### Option C: Invented generic code names unrelated to mythology or tech
E.g. "Sentinel" for Keycloak, "Inspector" for pgweb. Avoids tech leakage but abandons the mythological theme established by ADR-0003.

## Decision Rationale

Option B was chosen: it satisfies both drivers simultaneously — tech-agnostic naming *and* staying in the established mythological vocabulary — without inventing an unrelated naming scheme (Option C) or leaving the theme incomplete (Option A). Erebus specifically resolves the realm/database collision by giving the auth boundary its own distinct identity, separate from the Underworld's structural data.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| Consistent, tech-agnostic vocabulary across every resource a developer sees in the Aspire dashboard | A newcomer must learn the mapping (Hecate = Keycloak, Anamnesis = pgweb) instead of recognizing the product name instantly |
| Realm (`erebus`) and database (`underworld`) names no longer collide in logs/config | One more rename pass across realm JSON, redirect URIs, and README each time a new tech-agnostic persona is introduced |

## Consequences

### Positive
- `Oidc__Realm=erebus` next to a Postgres connection string for database `underworld` is now unambiguous.
- The shared library's name (`Chaos`) no longer implies it's disposable ASP.NET Core boilerplate — it's the foundation every project builds on, including the shared Underworld domain types.

### Negative
- Search-ability suffers slightly: grepping the codebase for "keycloak" or "pgweb" no longer finds the resource declarations directly (only the underlying package references).

### Neutral
- The Keycloak client id `cerberus-web` was left as a literal client identifier (not a persona name) since it's a technical OAuth client id, not a user-facing role name.

## Related Decisions

- [ADR-0003](./0003-adopt-mythological-naming-taxonomy.md) — establishes the mythological taxonomy this decision extends to infrastructure UIs and shared code.
- [ADR-0006](./0006-extend-persona-naming-to-doc-tooling.md) — extends the same tech-agnostic persona naming to the architecture-documentation tooling (Structurizr Lite, tech-radar).

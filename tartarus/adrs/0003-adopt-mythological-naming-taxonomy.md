# 0003. Adopt a consistent mythological naming taxonomy

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-21

## Status

Accepted

## Decision Outcome

Rename the solution to **Tartarus** and drop the `Cerberus.` prefix from every project so each project folder/csproj carries its own single mythological persona name (`Hades`, `Charon`, `Cerberus`, `Minos`, `ServiceDefaults` → later `Chaos`), matching the Aspire resource names already in use.

## Context

The spike started life as `Cerberus.sln` with projects named `Cerberus.AppHost`, `Cerberus.ApiService`, `Cerberus.Web`, `Cerberus.Minos`, and `Cerberus.ServiceDefaults`. Once Aspire resources were also named after mythological personas (`charon`, `cerberus`, `minos`, `styx`, `mnemosyne`), the `Cerberus.` prefix stopped meaning "the whole solution" and started meaning nothing in particular — worse, `Cerberus.Web` became the resource literally named `cerberus`, while the *solution* was also called Cerberus, creating a naming collision between "the frontend" and "the whole spike".

## Decision Drivers

- No project folder/csproj name may collide with, or be mistaken for, the solution's own name.
- Every project name should either be a mythological persona matching its Aspire resource name, or a plain, honest label if no persona fits (`ServiceDefaults`, later renamed to `Chaos` — see the shared-infra reasoning captured in the narrative doc).
- Renames must preserve git history (`git mv`) and not change any runtime behavior — Aspire resource names, connection strings, and realm data are out of scope for this decision.

## Considered Options

### Option A: Keep the `Cerberus.` prefix, rename only the solution
Rename `Cerberus.sln` → `Tartarus.sln` but leave all project folders as `Cerberus.ApiService`, `Cerberus.Web`, etc. Minimal churn, but the collision between "Cerberus the frontend" and "Cerberus the (former) solution/prefix" remains half-solved — the prefix is now just orphaned baggage.

### Option B: Full mythological rename, drop the prefix entirely
Rename the solution to Tartarus (the primordial deity/deepest region that mythologically contains the whole Underworld lineage — a fitting umbrella for Cerberus, Charon, Minos, Styx, and Mnemosyne) and rename every project folder/csproj to its bare persona name, with the AppHost renamed to **Hades** (ruler of the Underworld — the orchestrator that stands up and governs every other resource).

### Option C: Generic solution name, keep personas only at the resource level
Rename the solution to something generic like `UnderworldSpike` and leave project folders as-is. Avoids any mythological-name collision risk but abandons the theme at the solution level, which was an explicit goal.

## Decision Rationale

Option B was chosen because it's the only option that actually removes the naming collision rather than relocating it, and it keeps the theme consistent end-to-end (solution → project folder → Aspire resource all use the same vocabulary). Tartarus was picked for the solution specifically because of its mythological relationship to Cerberus (via Typhon) and its role as the encompassing region of the underworld, making it a natural "container" name distinct from any single inhabitant. Hades was picked for the AppHost because the AppHost's job — standing up and governing every other resource — mirrors Hades' role as ruler of the whole realm.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| No more ambiguity between "the solution" and "the frontend project" — each name is now unique and means one thing | Non-trivial one-time churn: 5 folder renames, 5 csproj renames, every namespace/`using`/`ProjectReference` touched |
| Namespaces read naturally (`namespace Charon;`, `namespace Cerberus;`) instead of stuttering (`namespace Cerberus.ApiService;`) | Contributors familiar with the old `Cerberus.*` project names need to relearn the new layout |

## Consequences

### Positive
- `Tartarus.sln` unambiguously refers to the whole spike; `Cerberus/` refers unambiguously to the frontend project.
- Every project's default namespace/assembly name now matches its folder and its Aspire resource name, reducing cognitive mapping overhead.

### Negative
- Git history for renamed files is preserved via `git mv`, but any external bookmarks/links to the old `Cerberus.ApiService`/`Cerberus.Web` paths are now stale.

### Neutral
- `ServiceDefaults` was renamed again shortly after this decision, to `Chaos` — see [ADR-0004](./0004-adopt-tech-agnostic-persona-naming.md)'s related discussion and the narrative doc for that follow-up.

## Related Decisions

- [ADR-0004](./0004-adopt-tech-agnostic-persona-naming.md) — extends the same naming discipline to infrastructure UIs (Keycloak, pgweb) and to the shared-infra project itself.
- [ADR-0006](./0006-extend-persona-naming-to-doc-tooling.md) — extends the same naming discipline to the architecture-documentation tooling (Structurizr Lite, tech-radar).

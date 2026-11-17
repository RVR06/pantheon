# 0006. Extend persona naming to doc tooling

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-02

## Status

Accepted

## Decision Outcome

Rename the two AppHost resources introduced for self-documentation — the Structurizr Lite renderer and the JavaScript tech-radar app — from their literal, generic identifiers (`archi`, `tech-radar`) to mythological personas: **Clio**, Muse of History, daughter of Mnemosyne; and **Themis**, Titaness of order and prophecy, once keeper of the Delphic Oracle. The underlying folder paths (`_archi/`, `_radar/`) and the spiker skill's `!adrs`/`!docs` directives stay literal and unchanged — only the resource identifiers, C4 container identifiers, and user-facing display names are renamed.

## Context

ADR-0003 established a mythological naming taxonomy for every Aspire resource, and ADR-0004 extended it to infrastructure UIs with tech-agnostic persona names (Hecate, Anamnesis, Chaos). Both decisions predate the `archi`/`tech-radar` resources: they were wired into `Hades/AppHost.cs` afterward, while retroactively applying the spiker skill's architecture-documentation discipline to this spike, and were left with their literal, generic identifiers. That broke the theme for the two resources a developer sees right alongside every other persona-named resource in the Aspire dashboard.

## Decision Drivers

- Every resource visible in the Aspire dashboard should carry a persona name, consistent with ADR-0003/ADR-0004 — no literal or generic leftovers.
- The folder paths (`_archi/`, `_radar/`) and the spiker skill's `!adrs adrs` / `!docs docs` directives are fixed, cross-spike conventions owned by the skill itself, not by this spike's theme — they must stay untouched, mirroring the ADR-0004 precedent where Hecate (Keycloak) kept its technical path `realms/erebus.json` unchanged while only the resource name changed.
- Candidate names must stay within the existing Greek mythology/pantheon vocabulary already used throughout the spike, and must not collide with existing identifiers (e.g. the `UnderworldAtlas` C# class name ruled out "Atlas" as a candidate for the Structurizr resource).

## Considered Options

### Option A: Keep literal names (`archi`, `tech-radar`)
Lowest churn, but leaves exactly the two meta/tooling resources inconsistent with every other resource's persona naming.

### Option B: Mythological personas surfacing each resource's role
- **Clio** — Muse of History, daughter of Mnemosyne (already a container in this spike) — she narrates what Mnemosyne remembers, a fitting persona for the resource that renders the C4 model, ADRs, and narrative doc.
- **Themis** — Titaness of law, order, and prophecy, who once held the Delphic Oracle before Apollo — fitting for the resource that forecasts/tracks technology adoption trends.
- Alternatives considered and rejected: Calliope and Atlas for the Structurizr resource (Atlas risked confusion with the existing `UnderworldAtlas` class); Pythia and Moira for the tech-radar resource (Themis was preferred for her order/counsel framing alongside the oracle tie-in).

### Option C: Invented generic code names unrelated to mythology
E.g. "Scribe" for Structurizr Lite, "Forecast" for the tech-radar. Avoids any collision risk but abandons the mythological theme established by ADR-0003.

## Decision Rationale

Option B was chosen: it closes the last gap in the ADR-0003/ADR-0004 naming taxonomy without inventing an unrelated naming scheme (Option C) or leaving two resources permanently inconsistent (Option A). Keeping the folder paths and skill directives literal (per the decision drivers) preserves the spiker skill's cross-spike tooling conventions, exactly as Hecate's realm file path was left untouched in ADR-0004.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| Every resource in the Aspire dashboard now carries a persona name, with no literal/generic leftovers | A newcomer must learn one more mapping (Clio = Structurizr Lite, Themis = tech-radar) instead of recognizing the tool name instantly |
| Consistency with the skill's cross-spike folder conventions, since `_archi/`/`_radar/` and the `!adrs`/`!docs` directives stay untouched | One more rename pass (AppHost.cs, workspace.dsl, narrative doc, README, radar entry) each time a new meta/tooling resource is introduced |

## Consequences

### Positive
- `clio` and `themis` now read consistently alongside `hecate`, `styx`, `mnemosyne`, and every other resource name in the Aspire dashboard and in `workspace.dsl`.
- Clio's name reinforces the existing Mnemosyne tie-in (mother/daughter), making the architecture-documentation resources feel native to the spike's own theme rather than bolted on.

### Negative
- Search-ability suffers slightly: grepping the codebase for "structurizr" or "radar" no longer finds the resource declarations directly (only the underlying package/image references).

### Neutral
- `_archi/workspace.json`, Structurizr Lite's generated cache of `workspace.dsl`, is regenerated automatically on container start and was removed from git tracking (added to `.gitignore`) rather than hand-edited, since it would otherwise drift stale on every future `workspace.dsl` change.

## Related Decisions

- [ADR-0003](./0003-adopt-mythological-naming-taxonomy.md) — establishes the mythological taxonomy this decision extends to the architecture-documentation tooling.
- [ADR-0004](./0004-adopt-tech-agnostic-persona-naming.md) — the precedent for keeping technical/folder paths unchanged while only renaming the resource identifier.

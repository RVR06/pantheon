---
title: "Structurizr Lite"
ring: "assess"
quadrant: "tools-and-patterns"
tags: [architecture, c4]
---

Structurizr Lite is a free, self-hosted, single-workspace version of Structurizr that renders a C4 model authored in Structurizr DSL, plus surfaces linked ADRs and narrative docs directly in its UI.

We introduced it into the Tartarus spike itself as part of retroactively applying the spiker skill's architecture-documentation discipline — wiring it as the `clio` AppHost resource (Clio, Muse of History) bind-mounted to `_archi/`, alongside the `themis` tech-radar site, so the spike documents its own architecture as it's built.

## Context

This spike had already been built (RabbitMQ/Styx, Postgres/Mnemosyne, full mythological renaming) before the discipline of wiring `clio`/`themis` resources and authoring ADRs/C4 models/radar entries as-you-go existed as a mandatory step. This entry — and the C4 model, ADRs, and narrative doc it accompanies — is itself the first real-world exercise of that discipline, applied retroactively using conversation history as the source record.

## Assessment

Structurizr Lite requires no license and runs as a single container bind-mounted to a live-editable folder, reloading `workspace.dsl`, `adrs/`, and `docs/` on refresh — well suited to a spike's iterate-in-place workflow. Because this is the first spike to use it, there's no track record yet of how well the C4-model-plus-ADR-plus-radar combination holds up as a spike evolves further after this point (new dependencies, new decisions).

## Recommendation

The pattern sits in assess: the mechanics (bind mount, live reload, ADR/docs auto-surfacing) worked cleanly for this retrofit, but the real test — keeping `workspace.dsl`/ADRs/narrative updated incrementally *during* active development, rather than backfilled once — hasn't happened yet for this spike.

## Next Steps

- Keep `_archi/workspace.dsl`, `_archi/adrs/`, and `_archi/docs/` updated incrementally the next time a new dependency or decision is introduced in this spike, to validate the "as you go" discipline in practice
- Revisit this entry's ring after that next real update cycle

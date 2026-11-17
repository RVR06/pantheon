# 0007. Scope the Kubernetes publish target to deployable resources

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-21

## Status

Accepted

## Decision Outcome

Register a single Kubernetes compute environment (`tartarus`) so `aspire publish -o <dir>` emits a real Helm chart, exclude the two meta/tooling resources (Clio, Themis) from the published graph via `builder.ExecutionContext.IsRunMode`, and switch Hecate's realm seeding from `WithRealmImport` (a dev-only bind mount) to `WithDockerfile` (a custom Keycloak image baked at publish time) — the officially documented production alternative. Run mode (`aspire run`) is unaffected: it still uses bind mounts and `WithRealmImport` exactly as before.

## Context

`aspire publish -o k8s-artifacts` reported `✓ Pipeline succeeded` but never created the output directory at all. The AppHost had no `Aspire.Hosting.Kubernetes` package reference and no `AddKubernetesEnvironment(...)` call — without a registered compute environment, the publish pipeline has nothing to target and silently no-ops instead of failing loudly. Once a Kubernetes environment was added, two further incompatibilities surfaced, both stemming from the same root cause: the Kubernetes publisher categorically rejects bind mounts (`System.InvalidOperationException: Bind mounts are not supported by the Kubernetes publisher`), since a cluster node has no equivalent of "the local machine's filesystem":

1. Clio (Structurizr Lite) bind-mounts `../_archi` to render the C4 model/ADRs/narrative doc.
2. Hecate (Keycloak) uses `.WithRealmImport("./realms")`, which is implemented as a bind mount and is explicitly documented as dev-only — unsupported when publishing or deploying.

## Decision Drivers

- `aspire publish` should either produce a working Helm chart or fail with a clear error — never silently succeed with no output.
- Clio and Themis are self-documentation/tooling resources, not part of the deployed app's runtime topology; they should never have needed a production deployment story in the first place.
- Keycloak realm seeding must keep working identically in local dev (`aspire run`), with no change to the day-to-day inner-loop experience.
- Prefer the officially documented Aspire pattern over a workaround, per this spike's standing convention of capturing any workaround in an ADR.

## Considered Options

### Option A: Give every resource a Kubernetes-compatible volume strategy
Replace Clio's and Hecate's bind mounts with named data volumes (`.WithDataVolume()`, which maps to a `PersistentVolumeClaim`). Rejected for Clio/Themis: a `PersistentVolumeClaim` has no way to receive the host-side `_archi`/`_radar` folder contents at all, since there's no `aspire publish`-time step that copies local files into a cluster-managed volume for these resources — the premise of "render whatever is on disk right now" doesn't translate to a durable deployment. For Hecate, a PVC still wouldn't solve how the realm JSON gets *into* the volume in the first place.

### Option B: Exclude Clio/Themis from publish; bake Hecate's realm into a custom image (chosen)
- Wrap the Clio/Themis resource declarations in `if (builder.ExecutionContext.IsRunMode) { ... }`, the idiomatic Aspire pattern for resources that should only exist during local development.
- Keep `.WithRealmImport("./realms")` for `aspire run`, but call `.WithDockerfile("./realms")` for `aspire publish`/`aspire deploy`, pointing at a new `Hades/realms/Dockerfile` that layers `quay.io/keycloak/keycloak:26.6` (the tag pinned by the installed `Aspire.Hosting.Keycloak` package) with `COPY ./*.json /opt/keycloak/data/import/` — the same folder as `erebus.json`, so there's no second copy of the realm file to keep in sync.
- Replace the two `() => hecate.GetEndpoint("http").Url` environment-variable callbacks (Charon's and Cerberus's `Oidc__IssuerBaseUrl`) with `ReferenceExpression.Create($"{hecate.GetEndpoint("http")}")`: the `Func<string>` form eagerly resolves a concrete URL, which requires an endpoint already allocated by a running container — something that doesn't exist at Kubernetes-manifest-generation time. `ReferenceExpression` instead defers evaluation, yielding the same concrete `localhost` URL in run mode and a Helm value placeholder (`{{ .Values.config.charon.HECATE_HTTP }}`) in publish mode.

### Option C: Drop Kubernetes publish support entirely, keep Docker Compose/manual deployment only
Rejected: the user explicitly asked for `aspire publish -o k8s-artifacts` to work, and Aspire's own Kubernetes integration exists precisely to cover this case without hand-written manifests.

## Decision Rationale

Option B was chosen because every piece of it maps to an officially documented Aspire pattern rather than an invented workaround: `IsRunMode` conditionals for dev-only resources, `WithDockerfile` as Keycloak's documented production realm-seeding alternative, and `ReferenceExpression` as the documented way to keep a cross-resource reference valid across both run and publish phases. Option A would have required inventing an unsupported way to get host files into a cluster volume at publish time. Option C abandons the feature the user asked for.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| `aspire publish -o k8s-artifacts` now generates a real Helm chart (Deployments/StatefulSets/Services/ConfigMaps/Secrets) for every resource that's actually part of the deployed app | Clio and Themis have no Kubernetes deployment story at all — if this spike's doc tooling is ever needed in a deployed cluster, it needs its own future decision |
| Hecate's realm seeding uses the same documented path Aspire recommends for every Keycloak-based app going to production | A second artifact (`Hades/realms/Dockerfile`) must be kept in mind alongside `erebus.json`, even though both still live in the same folder |

## Consequences

### Positive
- `aspire publish -o k8s-artifacts` succeeds and produces a populated Helm chart; previously it silently produced nothing.
- Clio/Themis correctly never appear in the generated manifests — they were never meant to be deployed.
- The `Oidc__IssuerBaseUrl` fix benefits both resources that reference Hecate (Charon and Cerberus) without changing their run-mode behavior at all.

### Negative
- The Keycloak image tag (`26.6`) baked into `Hades/realms/Dockerfile` is pinned by hand and must be revisited if `Aspire.Hosting.Keycloak`'s own default tag changes in a future package upgrade.

### Neutral
- Helm v4.2.0+ is the documented minimum for Aspire's Kubernetes publish/deploy pipeline; this environment currently has v4.1.1, which hasn't blocked manifest *generation* (this ADR's scope) but may block a later `aspire deploy` / `helm install` step — tracked as a separate, environment-level prerequisite rather than a code change.

## Related Decisions

- [ADR-0004](./0004-adopt-tech-agnostic-persona-naming.md) — the precedent for keeping a resource's technical path (`realms/erebus.json`) unchanged while its production wiring evolves.
- [ADR-0006](./0006-extend-persona-naming-to-doc-tooling.md) — establishes Clio/Themis as meta/tooling resources distinct from the spike's own runtime topology, the premise this decision relies on to exclude them from publish.

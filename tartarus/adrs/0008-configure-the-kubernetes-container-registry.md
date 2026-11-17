# 0008. Configure the Kubernetes container registry and namespace

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-21

## Status

Accepted

## Decision Outcome

Register a container registry resource, **Hephaestus**, so `aspire deploy`/`aspire do push` has somewhere to push images to, and attach it to the Kubernetes environment with `WithContainerRegistry`. Alongside it, the target Kubernetes namespace is configured via `WithHelm(helm => helm.WithNamespace(...))`. All three values — registry endpoint, registry repository, and namespace — are plain Aspire parameters with **no default value** — every deployer supplies their own via `Parameters:registry-endpoint`/`registry-repository`/`k8s-namespace` (appsettings/user secrets) or `Parameters__registry_endpoint`/`Parameters__registry_repository`/`Parameters__k8s_namespace` environment variables, or is interactively prompted by Aspire if they're left unset. Because the committed `Hades/aspire-output` chart is also consumed directly via `helm install`/`helm upgrade` (not only through `aspire deploy`), a `Hades/aspire-output/values.xxx.yaml` template is committed showing the registry/repository override shape with placeholder values; any deployer's own filled-in `Hades/aspire-output/values.xxx.yaml` overlay is gitignored, so no deployer's actual registry/repository/namespace combo ever lands in source control.

## Context

ADR-0007 got `aspire publish -o k8s-artifacts` emitting a real Helm chart, but every image reference in the generated `values.yaml` was still a bare, unqualified placeholder (`charon:latest`, `hecate:latest`, ...) — accurate per Aspire's own docs ("if you haven't specified custom container images, the generated `values.yaml` contains placeholders that you override at deployment time"), but not yet pointing anywhere a cluster could actually pull from. Without a registry, `aspire deploy` has no destination to push locally-built images to, and a plain `helm install` of the committed chart has no way to resolve `charon:latest` against any real registry. The chart also had no target namespace configured, so `aspire deploy` fell back to Helm's own `default` namespace rather than wherever a given deployer actually wants Tartarus to live. This spike is meant to land in a shared team repository, where no single deployer's personal registry/repository/namespace combo belongs in a file everyone checks out.

## Decision Drivers

- `aspire deploy`'s build-and-push pipeline needs a registry to push images to and a Helm chart to configure for pulling from it.
- The target Kubernetes namespace is just as deployer-specific as the registry: defaulting to Helm's own `default` namespace would silently put every deployer's release in the same place, with no obvious override.
- The committed `Hades/aspire-output` chart must also work standalone via plain `helm install`/`helm upgrade` (e.g. from a CI/CD pipeline that never calls `aspire` directly), independent of whether the deployer ever runs `aspire deploy`.
- No specific registry/repository/namespace value should ever be committed: every deployer's target could be entirely different in kind, not just value — a personal remote registry (ACR, GHCR, Docker Hub), a team-shared one, or a registry local to their own cluster flavor (kind, k3s, Docker Desktop's built-in Kubernetes).
- Every AppHost resource identifier in this spike carries a mythological persona (ADR-0003/0004/0006); the registry resource is no exception.

## Considered Options

### Option A: Hardcode a registry endpoint/repository as literal strings in `AppHost.cs`
Simplest, but bakes one person's specific registry path into source, forcing every other deployer to edit `AppHost.cs` locally (and risk committing it back) just to publish their own images. Rejected outright: this is exactly the kind of internal-detail leakage this spike's "agnostic enough to merge into a team repo" goal rules out.

### Option B: Aspire parameters with no default, resolved per-deployer + a gitignored Helm values overlay with a committed example template (chosen)
- `builder.AddParameter("registry-endpoint")` / `builder.AddParameter("registry-repository")` (no value argument) feed `AddContainerRegistry` — Aspire's own documented pattern for this exact scenario. Nothing in source implies or defaults to any particular registry; `aspire run`/`publish`/`deploy` prompts for both values (or reads them from each deployer's own `appsettings.json`/user secrets/environment) if unset.
- `builder.AddParameter("k8s-namespace")` feeds `WithHelm(helm => helm.WithNamespace(...))` the same way — no default, so every deployer targets their own namespace (personal, team, or environment-scoped) instead of everyone landing in `default`.
- `Hades/aspire-output/values.*.yaml` is gitignored wholesale, so any deployer's filled-in Helm values overlay (`values.xxx.yaml`, whatever `xxx` they pick) never reaches git. `Hades/aspire-output/values.xxx.yaml` is committed instead, with placeholder `<registry-endpoint>/<registry-repository>/...` text documenting the shape without encoding anyone's real values.

### Option C: Bake one registry path directly into the committed `values.yaml`
Rejected: it would silently point the shared, committed chart at one person's registry for every deployer, with no override needed (or obvious) to point it elsewhere — the opposite of agnosticism this decision is meant to achieve.

## Decision Rationale

Option B keeps every registry- and namespace-specific detail — in `AppHost.cs` and in the Helm values layer alike — entirely out of what's committed, while still giving both deployment paths (`aspire deploy`'s own build/push pipeline, and a standalone `helm install`/`helm upgrade` of the committed chart) a documented, working route to whatever registry and namespace each deployer actually uses. Option A trades this for simplicity at the cost of hardcoding one person's path into shared source. Option C solves the standalone-Helm case but pollutes the chart every deployer shares.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| Zero registry- or namespace-specific detail committed anywhere in the repo, in either the AppHost parameters or the Helm values layer | A deployer must supply all three values themselves (via config, env var, or Aspire's interactive prompt) before `aspire deploy`/`aspire do push` can run, and must create their own `values.xxx.yaml` from the committed example before a direct `helm install` works |
| The committed `Hades/aspire-output/values.yaml` and `AppHost.cs` stay registry- and namespace-agnostic, safe to share across teammates and across registry kinds (remote or local-cluster) | The actual filled-in Helm values override never exists in git history, so there's no shared, versioned record of what any given deployer used - purely a local/personal artifact by design |

## Consequences

### Positive
- `helm template ./Hades/aspire-output -f ./Hades/aspire-output/values.xxx.yaml` (a deployer's own override file, filled in locally from the committed `values.xxx.yaml`) correctly resolves `hecate`, `charon`, `minos`, and `cerberus` to whatever registry/repository the deployer supplied, verified directly against the rendered manifests.
- Hephaestus's registry/repository parameters and the `k8s-namespace` parameter work identically whether the target is a remote registry/cluster or one fronting a local cluster (kind/k3s/Docker Desktop), since nothing in `AppHost.cs` assumes either.

### Negative
- `AddContainerRegistry`/`WithContainerRegistry` are preview APIs (`ASPIRECOMPUTE003`), so this wiring may need revisiting on a future Aspire upgrade.
- Unlike the registry parameters (only consumed by `aspire deploy`'s push pipeline), `k8s-namespace` is resolved eagerly during chart generation itself — `aspire publish` in a non-interactive shell fails outright if it's unset, rather than emitting a chart with an unresolved placeholder. A deployer running `aspire publish`/`aspire deploy` non-interactively (e.g. CI) must supply it up front via config or `Parameters__k8s_namespace`.

### Neutral
- A deployer who skips both the parameter configuration and the Helm values overlay will be interactively prompted by Aspire for the registry/repository/namespace values at `run`/`publish`/`deploy` time (namespace only for those invocation modes where an interactive terminal is available — see Negative above), and will see the unqualified `<resource>:latest` placeholders if they `helm install` the chart directly without a values overlay - both are explicit, visible failure points, not a silent wrong-registry push.

## Related Decisions

- [ADR-0007](./0007-scope-kubernetes-publish-to-deployable-resources.md) — got `aspire publish` emitting a real Helm chart; this decision gives that chart's images somewhere to pull from, without naming any specific place.
- [ADR-0004](./0004-adopt-tech-agnostic-persona-naming.md) — the mythological-persona precedent this decision's "Hephaestus" naming follows.

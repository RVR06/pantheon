# 0011. Front Hecate, Cerberus, and the dashboard with Traefik IngressRoutes

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-21

## Status

Accepted

## Decision Outcome

Hand-author three Traefik `IngressRoute` manifests directly inside the committed `Hades/aspire-output` chart (`Hades/aspire-output/templates/hecate/ingressroute.yaml`, `Hades/aspire-output/templates/cerberus/ingressroute.yaml`, `Hades/aspire-output/templates/tartarus-dashboard/ingressroute.yaml`), driven by eight new Aspire parameters wired in via `.WithEnvironment(...)` on the Hecate, Cerberus, and dashboard resources: `ingress-hostname-hecate`, `ingress-hostname-cerberus`, `ingress-hostname-dashboard`, `ingress-entry-point`, `ingress-cert-resolver`, and one `ingress-middleware-<resource>` parameter per resource (`ingress-middleware-hecate`, `ingress-middleware-cerberus`, `ingress-middleware-dashboard`) - all eight with no default, the same no-hardcoded-personal-infra convention as ADR-0008's registry/namespace parameters. `ingress-entry-point` and `ingress-cert-resolver` are each attached to all three resources (not just the dashboard), so every `IngressRoute` template reads its own resource-local `config.<resource>.ingress_entry_point`/`ingress_cert_resolver` copy instead of reaching into another resource's config section - Aspire names each generated Helm config section after the resource it's attached to, so there's no genuinely shared/global section to point at just once. The deployer still only answers each parameter's prompt a single time regardless: Aspire de-duplicates deploy-time prompts per `ParameterResource`, not per `.WithEnvironment` attachment. Hecate also gets `KC_HOSTNAME` set to `https://<ingress-hostname-hecate>`, and its realm-import Dockerfile gets a new `CERBERUS_HOSTNAME` build argument that `sed`-substitutes Cerberus's fixed public hostname into `erebus.json`'s redirect URIs at image-build time. The dashboard additionally gets `DASHBOARD__FRONTEND__AUTHMODE=Unsecured`, since it relies entirely on the ingress-layer gate below instead of its own browser-token prompt. Each `ingress-middleware-<resource>` parameter holds a single, comma-separated list of Traefik Middleware names, rendered via a Helm `range (splitList "," ...)` loop - one key per ingress, not two - since every value supplied there is just "the Middlewares this route should carry," with no meaningful distinction at the parameter level between a "mandatory" entry and an "optional extra" one. All three resources are internet-facing, so a deployer is expected to always include the cluster's existing `oauth2-proxy` Middleware name as (at minimum) the first entry in each list - this is a network-edge gate, independent of and prior to each application's own user-facing login (Hecate *is* the login provider; Cerberus's "Login" button drives a real OIDC flow against Hecate after oauth2-proxy already let the browser through). There's no circularity: the cluster's `oauth2-proxy` authenticates against a separate Keycloak/IdP instance, not Hecate itself. The cluster conventionally exposes two oauth2-proxy Middleware variants - `oauth2-proxy-redirect` (sends an unauthenticated browser to the login page, for browser-facing UIs) and `oauth2-proxy-no-redirect` (returns a 401 instead, for backend/API calls) - all three being browser-facing, `oauth2-proxy-redirect` is the expected value; each parameter's own `.WithDescription(...)` documents this, plus how to append further Middlewares (rate-limiting, header-injection, ...) with additional comma-separated entries.

## Context

Each `aspire deploy` could previously land Hecate, Cerberus, and the dashboard behind whatever ephemeral hostname/port-forward the deployer happened to use that session, so Keycloak's advertised redirect URIs and web origins drifted from one deploy to the next - breaking login the moment the access URL changed. The target cluster already runs Traefik plus a shared `oauth2-proxy` deployment gating other apps in the namespace, and the deployer wants three fixed HTTPS hostnames (one each for Hecate/Keycloak, Cerberus/frontend, and the Aspire dashboard) so redirect URIs and web origins can be frozen once, and so the dashboard's telemetry is reachable without a second login layered on top of the oauth2-proxy gate already in front of it.

Aspire's own Kubernetes-manifest customization surface - `KubernetesResource.AddManifest` / `KubernetesManifestResource.WithField` - turned out to be `internal` in the real Aspire source, despite the shipped NuGet package's XML IntelliSense docs describing them in full (they're exercised only by polyglot JS/Python SDK bindings via source-generated exports, never by C# `AppHost.cs` code directly). No public Aspire API exists for emitting an arbitrary custom Kubernetes resource such as a Traefik `IngressRoute` from `AppHost.cs`.

Separately, values supplied via `Hades/aspire-output/values.xxx.yaml`-style overlay files (ADR-0008's pattern) are for manual, non-`aspire`-driven `helm install`/`helm upgrade` only - the deployer specifically wants this configured through Aspire's own parameters pattern (the same no-default-value, deploy-time-prompted mechanism already used for `registry-endpoint`/`registry-repository`/`k8s-namespace`), so a plain `aspire deploy` run resolves everything without a parallel values-file step.

## Decision Drivers

- No public Aspire API exists to emit a custom Kubernetes manifest (such as a Traefik `IngressRoute`) from `AppHost.cs`.
- The three target hostnames, the Traefik entry point, the cert resolver, and the oauth2-proxy middleware name are all deployer-/cluster-specific - none belong hardcoded in a shared chart, consistent with ADR-0008's no-default-value convention.
- The solution must be driven through Aspire's parameters pattern (prompted/stored the same way as `registry-endpoint`/`k8s-namespace`), not a `Hades/aspire-output/values.xxx.yaml` overlay, since the deployer uses that overlay path only for manual installs.
- Keycloak's OIDC discovery document always advertises whatever `KC_HOSTNAME` it's configured with, regardless of which hostname was actually used to fetch it - so only Hecate's own hostname setting needs to change to fix browser-facing redirect URLs; Charon's and Cerberus's existing internal `http://hecate-service:8080` discovery/token-validation wiring (already working) doesn't need to change.
- The realm's committed `erebus.json` must stay agnostic of any deployer's actual public hostname (same agnosticism goal as ADR-0008), yet still needs Cerberus's real hostname baked into its redirect-URI list for login to complete.
- The dashboard already sits behind the cluster's shared `oauth2-proxy` Traefik Middleware at the ingress layer; prompting for its own browser token on top of that is redundant friction.
- Hecate and Cerberus are deployed to a cluster that may be exposed over the internet, so neither should bypass the same network-edge `oauth2-proxy` gate just because each also runs its own application-level OIDC login flow - the two checks are complementary (edge gate, then per-user login), not alternatives.

## Considered Options

### Option A: `KubernetesResource.AddManifest`/`WithField` to emit the IngressRoutes from `AppHost.cs`
The ADR-0007-era plan, before the real Aspire source was checked. Rejected once confirmed both members are `internal`, not public - genuinely uncallable from this (or any) C# `AppHost.cs`, regardless of how complete their shipped XML docs look.

### Option B: Gateway API `HTTPRoute` via `AddGateway`/`WithRoute`
Aspire does expose a public Gateway API surface. Rejected: unconfirmed whether the target cluster has Gateway API CRDs/a Traefik `GatewayClass` installed at all, and Aspire's `WithRoute` sugar doesn't appear to support Traefik's `ExtensionRef` Middleware filters, which are required to attach the existing `oauth2-proxy` Middleware to the dashboard's route.

### Option C: Hand-authored `IngressRoute` templates inside the committed chart's existing resource folders, driven by Aspire parameters (chosen)
Empirically confirmed (via scratch `aspire publish` runs, cleaned up afterward) that: (1) a `Parameter` wired onto any resource via `.WithEnvironment(key, parameterBuilder)` produces a genuine Helm-value-backed placeholder in the chart (`{{ .Values.config.<resource>.<param-name> }}`, empty string committed, resolved by `aspire deploy`'s own deployment-state/`--set` mechanism - the same path already used for `registry-endpoint`/`k8s-namespace`); (2) the same `Parameter` object can be attached to several resources via several `.WithEnvironment(...)` calls, each producing its own `config.<resource>.<key>` entry with the same resolved value - letting every hand-authored template stay strictly self-referential (read only its own resource's config section) instead of reaching across into another resource's section, while the deployer still answers the underlying prompt once; (3) `aspire publish`/`aspire deploy` never purges unknown files already sitting inside an existing `Hades/aspire-output/templates/<resource>/` folder on regeneration - only their own known filenames (`deployment.yaml`, `config.yaml`, `secrets.yaml`, `service.yaml`, ...) are (re)written, confirmed via a throwaway marker file surviving a re-publish untouched. This makes hand-maintaining extra committed files inside those folders safe across repeated chart regenerations.

### Option D: `Hades/aspire-output/values.xxx.yaml` overlay carrying the ingress values
Rejected outright per the deployer's explicit direction: values overlays are reserved for manual, non-Aspire-driven installs; this needed to resolve through a plain `aspire deploy` run.

## Decision Rationale

Option C is the only path that both works with Aspire's actual public API surface and satisfies the parameters-pattern requirement: the eight new parameters behave identically to the already-established `registry-endpoint`/`registry-repository`/`k8s-namespace` parameters (no default, resolved by `aspire deploy`, interactively prompted if unset), while the `IngressRoute` manifests themselves - content Aspire has no public API to generate - are simply committed alongside the resources they front, confirmed safe from being clobbered by future chart regenerations.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| Three fixed HTTPS hostnames resolved entirely through `aspire deploy`'s own parameter mechanism, with no parallel values-file step | Three Kubernetes manifests (`ingressroute.yaml` per resource) that `aspire publish`/`aspire deploy` doesn't generate or know about - a human must keep them correct if a resource's Service name/port changes |
| Charon's and Cerberus's already-working internal OIDC discovery/token-validation wiring is untouched - only Hecate's `KC_HOSTNAME` and the realm JSON's redirect-URI list change | Eight more parameters to resolve on every `aspire deploy` run (on top of the three from ADR-0008), a larger prompt surface for a first-time deployer |
| The dashboard relies on the cluster's existing `oauth2-proxy` gate instead of prompting for its own browser token, one login instead of two | The dashboard's own auth is fully disabled (`DASHBOARD__FRONTEND__AUTHMODE=Unsecured`) - it now depends entirely on the ingress-layer middleware actually being present and correctly configured in whatever cluster it's deployed to |
| Hecate and Cerberus share the same edge-gate expectation as the dashboard - one `ingress-middleware-<resource>` parameter each, normally seeded with the cluster's `oauth2-proxy` Middleware name - so no internet-facing resource in this chart is meant to be reached without first clearing it | Hecate's and Cerberus's own OIDC login flows run *behind* that gate rather than replacing it - a deployer must keep `oauth2-proxy`'s backing IdP genuinely separate from Hecate to avoid confusing the two auth layers for one another, and must remember to actually include the oauth2-proxy name in the list themselves (nothing enforces it beyond documentation) |
| Every `IngressRoute` template reads its own resource's own `config.<resource>.ingress_entry_point`/`ingress_cert_resolver` - no template reaches across into another resource's config section | `ingress-entry-point`/`ingress-cert-resolver` are each attached to Hecate, Cerberus, *and* the dashboard, so the same answered-once value is stored three times in the generated chart rather than once - a small, deliberate duplication traded for keeping every template self-referential |
| The committed `erebus.json` stays free of any specific deployer's hostname - the real value is substituted at Docker image build time from a build argument | The realm JSON carries a `__CERBERUS_HOSTNAME__` placeholder token that only gets substituted via the Kubernetes-mode Dockerfile path; the plain-file `aspire run` dev path leaves it unsubstituted (harmless there - dev login never uses that redirect URI) |

## Consequences

### Positive
- `helm template`/`helm lint` against the regenerated chart render all three `IngressRoute` manifests correctly with real `--set` values, confirmed via scratch (non-live) runs.
- A throwaway marker file test confirmed hand-authored files inside existing `Hades/aspire-output/templates/<resource>/` folders survive repeated `aspire publish`/`deploy` regenerations untouched.
- Keycloak's OIDC discovery document now advertises the fixed public Hecate hostname for all browser-facing endpoints without any change to Charon's or Cerberus's existing (already-working) internal issuer/discovery configuration.

### Negative
- `AddManifest`/`WithField` being internal means this pattern - parameter-driven env vars plus hand-authored chart files - will need to be repeated for any future custom Kubernetes resource this spike needs, until/unless Aspire exposes a public manifest API.
- All three internet-facing resources (Hecate, Cerberus, and the dashboard) are entirely dependent on their respective `ingress-middleware-<resource>` parameter actually being set to the cluster's `oauth2-proxy` Middleware name for their network-edge gate; nothing at the parameter level enforces this (an empty or wrong value, or omitting the oauth2-proxy entry while adding an unrelated one, silently leaves that resource unauthenticated at the edge) - a larger blast radius than the dashboard alone.
- Whether the dashboard's `/oauth2/` callback path also needs registering against the cluster's existing (likely platform-managed) `oauth2-proxy` IngressRoute for its own hostname is unresolved - flagged in the `tartarus-dashboard/ingressroute.yaml` comments for the deployer to confirm per-cluster.

### Neutral
- Eight new parameters bring the running total of no-default deploy-time parameters to eleven (three from ADR-0008, eight from this decision); a future ADR may want to revisit whether some of these warrant sensible defaults (e.g. `ingress-entry-point` defaulting to `websecure`) once more than one cluster's conventions are known.

## Related Decisions

- [ADR-0008](./0008-configure-the-kubernetes-container-registry.md) — established the no-default-parameter, deploy-time-resolved pattern this decision reuses for the eight ingress parameters, and the `Hades/aspire-output/values.xxx.yaml`-for-manual-installs-only convention this decision deliberately does not use.
- [ADR-0010](./0010-run-hecate-over-plain-http-behind-the-kubernetes-ingress.md) — Hecate already runs plain HTTP behind a Kubernetes-level forwarder; this decision gives that ingress a fixed hostname and TLS termination instead of an ephemeral one.

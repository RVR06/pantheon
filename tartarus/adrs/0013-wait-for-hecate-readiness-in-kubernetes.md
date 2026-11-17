# 0013. Wait for Hecate readiness in Kubernetes

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-22

## Status

Accepted

## Decision Outcome

Attach a `wait-for-hecate` `initContainer` (plain `busybox:1.36`, polling Hecate's own OIDC discovery endpoint with `wget` in a retry loop) to Charon's and Cerberus's generated Kubernetes `Deployment`s, via `PublishAsKubernetesService` (`Hades/AppHost.cs`), rather than relying on `WaitFor(hecate)` alone.

## Context

Right after a fresh `aspire deploy`, logging into Cerberus (or calling Charon) sometimes failed with a 401, even though Hecate's pod was healthy seconds later. Cerberus's logs showed `IDX20803: Unable to obtain configuration from: 'http://hecate-service:8080/realms/erebus/.well-known/openid-configuration'` with the response body being unrelated HTML (a corporate SSO landing page briefly reachable at that service address during the narrow window before Hecate's Keycloak container had finished starting/importing the `erebus` realm). ASP.NET Core's `ConfigurationManager<OpenIdConnectConfiguration>` caches that failed discovery attempt and refuses to retry until its own backoff window elapses, so every login attempt in between kept failing even after Hecate became fully healthy.

`AppHost.cs` already declares `.WaitFor(hecate)` on both Charon and Cerberus, which correctly serializes startup order for local `aspire run`. Inspecting the generated chart confirmed the Kubernetes/Helm publisher doesn't translate `WaitFor` into any ordering primitive at all (no `initContainers`, no Helm hook, no readiness gate) - every Deployment starts concurrently as soon as `helm upgrade --install` applies them, so Charon/Cerberus can easily win the race against Hecate's own (slower) Keycloak boot + realm import.

## Decision Drivers

- The symptom is a genuine race condition, not a configuration bug in Hecate or Charon/Cerberus's OIDC setup - masking it with a longer client-side cache/backoff tweak would only reduce the odds of hitting it, not eliminate the window.
- `WaitFor` already correctly expresses the intended dependency in the AppHost model; the gap is specifically that the Kubernetes/Helm publisher silently drops it, so the fix should restore the same guarantee in Kubernetes rather than invent a different mechanism.
- Per this spike's standing convention, use Aspire's own supported customization API (`PublishAsKubernetesService`) over hand-editing generated chart files, which would be silently overwritten by the next `aspire publish`/`aspire deploy` (same rationale as ADR-0011's hand-authored `IngressRoute` templates living in their own untouched files rather than edited generated ones).

## Considered Options

### Option A: Do nothing, rely on the OIDC ConfigurationManager's backoff to self-heal
Technically accurate (the failure is transient and resolves itself within its backoff window), but leaves every fresh deploy with a few minutes of spurious 401s on login - a bad first impression for a demo/review audience, and easy to mistake for a real regression each time it happens.

### Option B: Tune ASP.NET Core's OIDC `ConfigurationManager` refresh/backoff interval down
Would shrink the window of repeated failures, but doesn't fix the root cause (Charon/Cerberus can still legitimately start and receive the first request before Hecate is ready), and couples a Kubernetes-only ordering problem to in-process HTTP client configuration that would also affect local `aspire run`, where the race doesn't exist.

### Option C: Add a `wait-for-hecate` `initContainer` via `PublishAsKubernetesService` (chosen)
Re-creates exactly the ordering `WaitFor(hecate)` already expresses, scoped to Kubernetes only (`if (!builder.ExecutionContext.IsRunMode)`), using Aspire's own supported resource-model customization hook instead of a hand-edited (and therefore regeneration-fragile) chart file. The init container blocks Charon's/Cerberus's main container from starting at all until Hecate's discovery endpoint actually responds with valid JSON, so the main container's very first OIDC call is guaranteed to succeed.

## Decision Rationale

Option C is the only one that removes the race itself rather than narrowing or tolerating it, and it does so using the same customization surface Aspire documents for exactly this kind of per-resource Kubernetes manifest adjustment.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| Charon's and Cerberus's pods never attempt their first OIDC discovery call before Hecate is actually serving it, eliminating the post-deploy 401 window entirely | A third container image (`busybox:1.36`) to pull per pod, and a hardcoded `hecate-service`/`erebus` literal pair in the init container's shell command (consistent with the same `hecate-service` internal-DNS convention already relied on by `KC_HOSTNAME`'s backend-discovery comment) |

## Consequences

### Positive
- Fresh `aspire deploy`s no longer produce a window of spurious 401s on Cerberus login or Charon calls while Hecate is still starting.
- The fix lives entirely in `AppHost.cs`, regenerates cleanly on every `aspire publish`/`aspire deploy` (confirmed via `helm lint` and diffing the regenerated `charon`/`cerberus` `deployment.yaml` templates), and touches no hand-authored chart files.

### Negative
- Pod startup is slightly slower on a fresh deploy (bounded by however long Hecate itself takes to finish booting and importing `erebus`), though this is strictly less total latency than the previous outcome of the pod starting fast and then failing logins for minutes.

### Neutral
- `aspire run`'s local orchestration is unaffected: the initContainer is only added in the `else` (deploy-mode) branch, since `WaitFor(hecate)` already works correctly for local runs.

## Related Decisions

- [ADR-0011](./0011-front-hecate-cerberus-and-the-dashboard-with-traefik-ingressroutes.md) — establishes the `hecate-service` internal-DNS convention this ADR's init container also relies on.
- [ADR-0007](./0007-scope-kubernetes-publish-to-deployable-resources.md) — the original precedent for preferring Aspire's own Kubernetes customization/build-time mechanisms over bind-mount-style local-run conveniences the publisher doesn't support.
- [ADR-0014](./0014-dynamic-backchannel-hostname-for-hecate.md) — this init container is still correct and kept as defense-in-depth against a genuine boot-order race, but it turned out **not** to be the full story: logins kept failing after it shipped, with a different exception (`jwks_uri` fetch, not the discovery document itself) that reproduced consistently, not just on fresh deploys. ADR-0014 fixes that separate, persistent root cause.

# 0010. Run Hecate over plain HTTP behind the Kubernetes ingress

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-21

## Status

Accepted

## Decision Outcome

Set `KC_HTTP_ENABLED=true`, `KC_PROXY_HEADERS=xforwarded`, and `KC_HOSTNAME_STRICT=false` as plain environment variables on the Hecate container in Kubernetes mode (`hecate.WithEnvironment(...)`, alongside the existing `WithDockerfile` call from ADR-0007), so Keycloak serves plain HTTP internally, trusts forwarded proxy headers to build correct redirect/cookie URLs, and stops requiring a fixed public hostname this spike doesn't have - rather than providing it a TLS certificate/key pair and a stable DNS name.

## Context

Hecate crash-looped in the Kubernetes deployment, first with `Key material not provided to setup HTTPS. Please configure your keys/certificates, or if HTTPS access is not needed see the http-enabled option.`, then - after enabling plain HTTP - with `hostname is not configured; either configure hostname, or set hostname-strict to false`. ADR-0007's Dockerfile has no explicit start command, so the baked image falls back to Keycloak's production profile - which, unlike the dev-mode `start-dev` command used by `aspire run`'s container, enforces both TLS and a configured hostname by default.

## Decision Drivers

- This is a disposable spike's single Kubernetes cluster, not a product with its own TLS/certificate rotation pipeline to stand up just for Hecate.
- Terminating TLS once at the cluster's own ingress/edge is standard practice for every workload in this cluster (the pre-existing `oauth2-proxy` deployment already running alongside Tartarus follows the same pattern) - Hecate shouldn't need to reinvent certificate management for itself alone.
- Per this spike's standing convention, use Keycloak's own officially documented configuration for this exact scenario rather than inventing a bespoke workaround.

## Considered Options

### Option A: Provide Hecate its own TLS certificate and key (`KC_HTTPS_CERTIFICATE_FILE`/`KC_HTTPS_CERTIFICATE_KEY_FILE`)
Works, but requires minting/mounting a certificate (self-signed or cluster-issued) solely for Hecate, plus keeping it readable by the container's non-root user - unnecessary certificate-management machinery for a spike that already terminates TLS at the cluster edge for every other workload.

### Option B: Run Keycloak over plain HTTP, trusting forwarded proxy headers, with hostname-strict relaxed (chosen)
Keycloak's own documentation describes exactly this setup for deployments behind a reverse proxy/ingress that already terminates TLS, without a fixed public hostname assigned up front: `KC_HTTP_ENABLED=true` disables the production profile's TLS requirement; `KC_PROXY_HEADERS=xforwarded` tells Keycloak to trust `X-Forwarded-*` headers from the proxy so it still builds `https://` redirect and cookie URLs correctly for clients, even though the hop into the pod itself is plain HTTP; `KC_HOSTNAME_STRICT=false` lets Keycloak infer its own hostname from each incoming request instead of requiring one configured in advance - appropriate for this spike's cluster-assigned, not-yet-fixed endpoint.

### Option C: Keep using `start-dev` in the published image too
Would avoid the TLS requirement entirely, but `start-dev` disables several production safeguards (e.g. it's explicitly documented as unfit for production use) purely to dodge a two-environment-variable fix - a worse tradeoff for a decision that's supposed to be about *not* reinventing Keycloak's own production guidance.

## Decision Rationale

Option B is Keycloak's own documented configuration for "TLS terminated upstream of me" - it needs no certificate material, no extra mounts, and no weakening of the production profile's other protections, unlike Option A (certificate management) or Option C (abandoning the production profile altogether).

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| Hecate starts reliably in Kubernetes with zero certificate/key material to generate, mount, or rotate, and no fixed hostname to reserve up front | Hecate now assumes it always sits behind a proxy/ingress that terminates TLS and sets `X-Forwarded-*` headers correctly, and infers its own hostname per request rather than enforcing one known value - acceptable for this spike's dynamic cluster endpoint, but a real production deployment would typically configure `KC_HOSTNAME` explicitly once a stable public hostname exists |

## Consequences

### Positive
- Hecate reaches Running/Healthy in the Kubernetes deployment without any certificate provisioning step.
- Matches the same "TLS terminated at the cluster edge, plain HTTP behind it" shape already used by the cluster's pre-existing `oauth2-proxy` deployment, rather than introducing a second, inconsistent pattern just for Hecate.

### Negative
- Hecate's OIDC consumers (Charon's `JwtBearer` authority, Cerberus's `OpenIdConnect` authority/metadata address) previously keyed `RequireHttpsMetadata` off `builder.Environment.IsDevelopment()`, assuming Production always meant an HTTPS authority. Once Hecate started serving plain HTTP internally in Kubernetes too (a genuinely Production environment), that assumption broke both services with `MetadataAddress or Authority must use HTTPS unless disabled...`. Fixed by deriving `RequireHttpsMetadata` from the authority URL's own scheme instead of the hosting environment, in both `Charon/Program.cs` and `Cerberus/Program.cs` - correct in every mode, since the authority is plain HTTP whenever `aspire run`'s dev-mode Keycloak container is used too.
- `hecate.WithDataVolume()` mounts a volume at `/opt/keycloak/data` - the same parent directory ADR-0007's baked image uses for `/opt/keycloak/data/import/erebus.json`. In Kubernetes that volume is an `emptyDir` (no real persistence across pod restarts/reschedules anyway), but it still fully shadowed the baked-in import directory, so Keycloak booted with an empty `import/` folder and silently never imported `erebus` - no error, just a missing realm (`{"error":"Realm does not exist"}` on every subsequent request). Fixed by only calling `.WithDataVolume()` in run mode (`builder.ExecutionContext.IsRunMode`), where it doesn't conflict with the separately bind-mounted realm import and does provide real restart persistence for the local dev container.

### Neutral
- `aspire run`'s local Keycloak container is unaffected: it still runs `start-dev`, which never enforced the production profile's TLS requirement, so this change is scoped entirely to the publish/deploy (`else`) branch.

## Related Decisions

- [ADR-0007](./0007-scope-kubernetes-publish-to-deployable-resources.md) — the `WithDockerfile` realm-baking fix this ADR builds directly on top of.

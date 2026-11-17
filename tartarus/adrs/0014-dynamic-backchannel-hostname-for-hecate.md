# 0014. Dynamic backchannel hostname for Hecate

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-22

## Status

Accepted

## Decision Outcome

Set `KC_HOSTNAME_BACKCHANNEL_DYNAMIC=true` on Hecate (`Hades/AppHost.cs`), alongside the existing fixed `KC_HOSTNAME`.

## Context

After ADR-0013's `wait-for-hecate` init container shipped, Cerberus logins still failed - consistently, not just right after a fresh deploy, and with a different exception than before: `IDX20803`/`IDX10805` deserializing JSON failed, with the response body being the organization's SSO login page HTML, not Keycloak JSON. The stack trace pointed at `JsonWebKeySet` construction, not the discovery document fetch itself.

Root cause: `KC_HOSTNAME` makes Keycloak advertise **every** endpoint in its OIDC discovery document - `authorization_endpoint`, `token_endpoint`, `jwks_uri`, etc. - using the one fixed public hostname, regardless of which hostname a given request actually arrived on. Charon/Cerberus fetch the discovery document from the internal `hecate-service:8080` address (so login keeps working across ingress/tunnel changes - see ADR-0011), but the document they get back still told them to fetch the signing keys (`jwks_uri`) and exchange the authorization code (`token_endpoint`) from the **public** hostname. Hecate's public ingress is gated by the cluster's `oauth2-proxy` Traefik middleware (ADR-0012), so Charon/Cerberus's own server-to-server call to fetch `jwks_uri` got intercepted by `oauth2-proxy` - which has no session cookie for a backend-to-backend call - and served the SSO login page instead of a JWKS JSON document. This reproduced on every login, not just a narrow startup window, which is why ADR-0013's initContainer fix didn't resolve it.

Confirmed via a disposable in-cluster `curl` pod: before this change, `jwks_uri`/`token_endpoint` in the discovery document fetched from `hecate-service:8080` pointed at the public `https://hecate.<host>` hostname; after setting `KC_HOSTNAME_BACKCHANNEL_DYNAMIC=true` and restarting Hecate/Charon/Cerberus, the same in-cluster fetch returned `jwks_uri`/`token_endpoint` using `http://hecate-service:8080` instead, while `authorization_endpoint`/`end_session_endpoint` (the ones a browser actually follows) correctly stayed on the public hostname.

## Decision Drivers

- Keycloak has an officially documented feature for exactly this split (frontchannel endpoints fixed/public, backchannel endpoints dynamically resolved from the request's own `Host` header) - prefer it over inventing a workaround.
- Carving path-based exceptions into the `oauth2-proxy` Traefik middleware (e.g. excluding `/realms/*/protocol/openid-connect/certs`) was considered and rejected: it would require enumerating and keeping in sync every backchannel OIDC path Keycloak might expose, is fragile against future Keycloak versions adding new backchannel endpoints, and weakens the "every internet-facing ingress sits behind oauth2-proxy, no exceptions" posture from ADR-0011 for no good reason, when Keycloak itself can resolve this without any ingress/middleware change at all.

## Considered Options

### Option A: Path-exclude backchannel OIDC endpoints from the oauth2-proxy middleware
Rejected - see decision drivers above: fragile, needs to track Keycloak's internal endpoint list, and erodes ADR-0012's "no exceptions" posture.

### Option B: Set `KC_HOSTNAME_BACKCHANNEL_DYNAMIC=true` (chosen)
Keycloak's own supported mechanism for a split frontchannel/backchannel hostname. No ingress/middleware changes, no new literals to keep in sync - Keycloak resolves the correct backchannel host directly from the incoming request's `Host` header for each caller.

## Decision Rationale

Option B fixes the problem at its actual source (Keycloak advertising the wrong host for backchannel-only endpoints) using the feature Keycloak ships for this exact split, rather than working around it from the ingress side.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| Charon/Cerberus's server-to-server JWKS/token calls never cross the public, oauth2-proxy-gated ingress again - login works reliably, not just outside a narrow startup window | `hostname-strict=false`-style dynamic resolution trusts the incoming request's `Host`/forwarded headers for backchannel URLs; already mitigated here since `KC_PROXY_HEADERS=xforwarded` is set and only trusted in-cluster callers (Charon, Cerberus, debug pods) can reach `hecate-service` directly |

## Consequences

### Positive
- Cerberus login and Charon's own OIDC token validation work reliably against a fresh deploy, not just after ADR-0013's startup race is avoided.
- No changes needed to `_helm/templates/hecate/ingressroute.yaml` or the `oauth2-proxy` middleware chain - ADR-0011's "no exceptions" posture is preserved.

### Negative
- None identified; this only affects which hostname backchannel-only endpoints are advertised under, not whether they're reachable.

### Neutral
- ADR-0013's `wait-for-hecate` init container is unaffected and still worth keeping as defense-in-depth against a genuine Keycloak-not-ready-yet race, which is a distinct problem from this one.

## Related Decisions

- [ADR-0010](./0010-run-hecate-over-plain-http-behind-the-kubernetes-ingress.md) — establishes `KC_PROXY_HEADERS=xforwarded`/`KC_HOSTNAME_STRICT=false`, relied on here too.
- [ADR-0011](./0011-front-hecate-cerberus-and-the-dashboard-with-traefik-ingressroutes.md) — establishes the fixed public `KC_HOSTNAME`, the internal `hecate-service` discovery convention this ADR refines, and the "every internet-facing ingress sits behind oauth2-proxy, no exceptions" posture this ADR avoids having to weaken.
- [ADR-0013](./0013-wait-for-hecate-readiness-in-kubernetes.md) — an earlier, necessary-but-insufficient fix for a related but distinct symptom (startup-order race vs. this ADR's persistent backchannel-hostname bug).

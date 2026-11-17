# 0015. Strip injected Authorization header for Hecate

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-22

## Status

Superseded by [ADR-0016](./0016-unexpose-hecate-admin-console.md)

## Decision Outcome

Chain a hand-authored `hecate-strip-authorization` Traefik `Middleware` (`Hades/aspire-output/templates/hecate/middleware.yaml`) **both before and after** `oauth2-proxy-redirect` in Hecate's `IngressRoute` (`Hades/aspire-output/templates/hecate/ingressroute.yaml`), removing any `Authorization` request header before `oauth2-proxy-redirect`'s own `forwardAuth` check runs, and again before the request reaches `hecate-service`. See "Amendment" below - the original single-strip-after placement did not fully resolve the reported 401.

## Context

After ADR-0014 fixed Cerberus's own login flow, the user reported a separate, persistent 401 when visiting Hecate's own admin console (`https://hecate.<host>/admin/master/console/`) directly in a browser - reproducible even in a fresh private/incognito window (so not a stale client-side token/cookie, which was the first hypothesis).

Inspecting the cluster's shared `oauth2-proxy-redirect` Traefik `Middleware` (a pre-existing, platform-managed resource this spike only references by name, not one defined in this chart) found:

```yaml
spec:
  forwardAuth:
    authResponseHeaders:
      - Authorization
      - X-Auth-Request-Access-Token
      - X-Forwarded-Email
      - X-Forwarded-User
      - X-Forwarded-Preferred-Username
```

After a user successfully authenticates against the cluster's own SSO via `oauth2-proxy`, this `forwardAuth` configuration injects an `Authorization` header (carrying the SSO-issued token) onto *every* request forwarded to whatever service sits behind it - a convenience for apps that want to consume the caller's identity via a trusted header. Keycloak's own Admin Console/Admin REST API, however, also inspects any incoming `Authorization: Bearer` header as an *alternative* authentication mechanism for its own API. It tries to validate the injected SSO token as one of its own (wrong issuer, wrong signer) and rejects the request with 401, instead of falling back to Keycloak's normal admin session - even for a user who has a perfectly valid `oauth2-proxy` session and would otherwise be let straight through.

This is a genuine conflict between two independent systems that both attach meaning to the standard `Authorization` header: `oauth2-proxy`'s convenience forwarding, and Keycloak's own Bearer-token admin auth. It does not affect Cerberus's own OIDC login (confirmed working after ADR-0014): Cerberus's ASP.NET backend performs its own cookie-based OIDC code flow and never treats an inbound request's `Authorization` header as an identity signal, so the injected header passes through harmlessly there.

## Decision Drivers

- `oauth2-proxy-redirect` is shared, platform-managed infrastructure (created long before this spike existed) used by potentially other apps in the namespace - mutating its `authResponseHeaders` to stop injecting `Authorization` globally would be a cluster-wide behavior change outside this spike's ownership, and could break whatever other app actually relies on that header.
- Per this spike's standing convention (ADR-0011, ADR-0013), prefer a fix fully contained in this chart's own hand-authored resources over asking for a change to shared infrastructure, when one is possible.
- The conflict is specific to Hecate (the only resource in this spike whose own backend attaches special meaning to `Authorization`); Cerberus and the dashboard don't need this same treatment.

## Considered Options

### Option A: Ask the platform team to stop injecting `Authorization` in `oauth2-proxy-redirect`
Out of scope for a self-contained fix, risks breaking other apps relying on that header, and would block on a team outside this spike.

### Option B: Reconfigure Keycloak to ignore Bearer tokens for the Admin Console
Not a supported/documented Keycloak configuration; the Admin REST API's Bearer-token auth path is integral to how admin tooling (and the Admin Console itself, which uses Bearer tokens for its own API calls after login) works - disabling it would break legitimate admin-token usage, not just the conflict.

### Option C: Strip the `Authorization` header before it reaches Hecate (chosen)
A `headers` Traefik `Middleware` with `customRequestHeaders: {Authorization: ""}`, chained immediately after `oauth2-proxy-redirect` in Hecate's own `IngressRoute`, removes the injected header before Keycloak ever sees it - scoped to Hecate only, fully contained in this chart, no changes to shared infrastructure.

## Decision Rationale

Option C is the only one that's both fully within this spike's own ownership and doesn't risk regressing other consumers of the shared `oauth2-proxy-redirect` middleware or Keycloak's legitimate Bearer-token admin auth.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| Hecate's admin console (and any other Keycloak endpoint that inspects `Authorization`) works correctly regardless of what `oauth2-proxy-redirect` injects, with zero changes to shared cluster infrastructure | If a future requirement needs Hecate to see the caller's SSO identity via that header (e.g. for an identity-brokering scenario), this middleware would need to be revisited/removed |

## Consequences

### Positive
- Hecate's admin console no longer 401s for a correctly-authenticated user, in a fresh/private browser session or otherwise.
- The fix is fully contained in `Hades/aspire-output/templates/hecate/` (new `middleware.yaml` + a one-line addition to `ingressroute.yaml`'s `middlewares` list), survives `aspire publish`/`aspire deploy` regeneration (the Aspire Helm writer only rewrites its own known filenames), and needs no `AppHost.cs` changes.
- `hecate-strip-authorization` is always appended last, after whatever Traefik Middleware names the deployer configured via `ingress-middleware-hecate`, so it applies regardless of what else is in that list.

### Negative
- None identified for this spike's current scope.

### Neutral
- Cerberus's and the dashboard's `IngressRoute`s are untouched; this is scoped to Hecate only, since only Keycloak's own backend attaches special meaning to an inbound `Authorization` header.

## Related Decisions

- [ADR-0011](./0011-front-hecate-cerberus-and-the-dashboard-with-traefik-ingressroutes.md) — establishes the hand-authored `IngressRoute` convention and the `ingress-middleware-hecate` configurable middleware list this ADR appends to.
- [ADR-0014](./0014-dynamic-backchannel-hostname-for-hecate.md) — the prior, distinct OIDC backchannel fix; this ADR addresses a separate conflict (Keycloak's own admin console vs. a header the platform's shared `oauth2-proxy-redirect` middleware injects), not a regression of that fix.

## Amendment (2026-10-22)

The original fix (strip `Authorization` *after* `oauth2-proxy-redirect` only) did not resolve the reported 401 - the user confirmed it still occurred, in a fresh private browser window, after this fix was deployed.

Re-investigation found the real mechanism is the *inbound* direction, not just the outbound one originally diagnosed: the cluster's `oauth2-proxy` is configured with `--skip-jwt-bearer-tokens=true`. This makes `oauth2-proxy`'s own `forwardAuth` check independently inspect any incoming `Authorization: Bearer` header on the *original* request and attempt to validate it itself, as an alternative to the cookie session - before the request ever reaches the `hecate-strip-authorization` middleware, which only ran *after* `oauth2-proxy-redirect` in the chain.

The browser's own Keycloak Admin Console JavaScript attaches its own admin access token (issued by Hecate's master realm) as an `Authorization: Bearer` header on same-origin XHR/fetch calls to Keycloak's admin REST API. When this reaches `oauth2-proxy`'s `forwardAuth` check, `oauth2-proxy` tries to validate it against the corporate SSO issuer, fails (`oidc: id token issued by a different provider, expected https://<corp-idp-host>/auth/realms/<corp-realm> got https://hecate.<host>/realms/master` - confirmed via live `oauth2-proxy` logs, `jwt_session.go:51`), and rejects with 401 - regardless of whether the browser also holds a perfectly valid `oauth2-proxy` cookie session.

**Fix**: `hecate-strip-authorization` is now chained twice: once *before* `oauth2-proxy-redirect` (so `oauth2-proxy`'s bearer-token check never sees the browser's own Keycloak-issued token, falling back to its normal cookie-session check) and once *after* (retaining the original protection - stripping the SSO token `oauth2-proxy` itself injects into the forwarded request on a successful cookie-session check, which Keycloak would otherwise also misinterpret as a Bearer auth attempt).

Verified live: `kubectl get ingressroute hecate-ingress -o jsonpath='{.spec.routes[0].middlewares}'` shows `["hecate-strip-authorization", "oauth2-proxy-redirect", "hecate-strip-authorization"]`; `helm template` confirms the same render from the committed chart. Awaiting final user confirmation against the live admin console.

## Superseded (2026-10-23)

The user reported a *new* symptom after the above fix: Keycloak's own login form now loaded and accepted admin credentials correctly, but the Admin Console still 401'd immediately after, on its own REST API calls.

This is an unavoidable consequence of stripping `Authorization` in both directions: removing it *after* `oauth2-proxy-redirect` also removes the corporate SSO token `oauth2-proxy` injects - but by that point there is no `Authorization` header left at all, including no legitimate Keycloak-issued one, since the Admin Console's own token is only attached by its JavaScript *after* a cookie-based page load, as a header on subsequent XHR calls to the admin REST API - which this chain strips unconditionally regardless of who attached it or why.

Further investigation (confirmed against Traefik's own `forwardAuth` documentation) found `authResponseHeaders` on the cluster's mandatory `oauth2-proxy-redirect`/`oauth2-proxy-no-redirect` Middleware **always overwrites** any existing `Authorization` header on every successful gate pass - there is no "inject only if absent" mode. A cluster-wide Kyverno policy (`enforce-auth-middleware`) additionally mandates that every `IngressRoute` include one of `oauth2-proxy-redirect`, `oauth2-proxy-no-redirect`, or `traefik-forward-auth` **by name**, blocking any attempt to substitute a custom clone with different header-filtering behavior - confirmed via a rejected `helm upgrade` admission-webhook response. No viable drop-in alternative exists in this namespace (`traefik-forward-auth` isn't deployed here).

There is consequently no header state (present, absent, or overwritten) under which Keycloak's Bearer-only Admin Console can work correctly behind this cluster's mandatory, platform-owned auth gate, short of building new relay infrastructure of our own (considered and deemed disproportionate - see ADR-0016).

This ADR's strip-based approach is abandoned in favor of [ADR-0016](./0016-unexpose-hecate-admin-console.md): rather than trying to let a legitimate `Authorization` header survive the gate, Hecate's public `IngressRoute` is scoped to exclude `/admin/*` entirely, so the conflict never arises on the public path. Admin access now goes exclusively through `kubectl port-forward`, which bypasses the public ingress (and therefore `oauth2-proxy`) altogether.

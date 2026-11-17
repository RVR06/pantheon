# 0016. Unexpose Hecate's Admin Console, keep only the OIDC frontchannel public

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-23

## Status

Accepted

## Decision Outcome

Scope Hecate's `IngressRoute` (`Hades/aspire-output/templates/hecate/ingressroute.yaml`) to only `/realms/*` and `/resources/*` via a `PathPrefix` match alongside the existing `Host` rule, and remove `hecate-strip-authorization` (`Hades/aspire-output/templates/hecate/middleware.yaml`, deleted) entirely. `/admin/*` (Keycloak's Admin Console and its Admin REST API) is no longer reachable through the public ingress at all. Admin access is exclusively via `kubectl port-forward svc/hecate-service 8080:8080 -n <namespace>`, then browsing `http://localhost:8080/admin/master/console/`.

## Context

ADR-0015 (now superseded) tried to let a legitimate `Authorization` header survive the cluster's mandatory `oauth2-proxy-redirect`/`-no-redirect` gate, by stripping it before and/or after that middleware. Every variant failed: stripping it both ways leaves *no* `Authorization` header at all once the Admin Console's own JavaScript needs one for its own REST API calls, and the gate's `authResponseHeaders` **always overwrites** any header that does survive, with no "inject only if absent" option. A cluster-wide Kyverno policy additionally forces every `IngressRoute` to use one of a fixed set of shared middleware names, blocking any custom clone with different header-filtering behavior. No namespace-local alternative middleware exists.

A tiny relay sidecar (bracketing the gate with `forwardAuth` middlewares that rename `Authorization` to a custom header before the gate and restore it after) was sketched out and is technically sound, but represents meaningfully new infrastructure (an extra container, two more Middleware resources, more moving parts to operate) for a problem that only affects the Admin Console - a feature this spike's regular users never touch, and which the deployer can already reach another way.

Separately, Cerberus's own login button cannot be served the same way: its OIDC authorization-code-flow redirect is *frontchannel* - the **browser itself** navigates to Hecate's `/realms/<realm>/protocol/openid-connect/auth` (and back to `/realms/<realm>/protocol/openid-connect/logout` for logout), so those paths must stay reachable from the public internet, unlike the backchannel `token_endpoint`/`jwks_uri` calls Charon/Cerberus's own backend already makes internally (ADR-0014). The Admin Console/REST API conflict never applies to those paths: Keycloak's regular login/registration pages and OIDC endpoints don't inspect an inbound `Authorization` header as a Bearer-auth signal the way the Admin REST API does, so dropping `hecate-strip-authorization` doesn't reintroduce the original conflict there.

## Decision Drivers

- The Admin Console/REST API vs. mandatory-gate conflict is structurally unfixable without new relay infrastructure (ADR-0015's amendment); building that infrastructure for an admin-only feature is disproportionate.
- Cerberus's end-user login flow must keep working - it genuinely needs the browser to reach Hecate's `/realms/*` endpoints directly, unlike the Admin Console.
- Narrowing the public surface to only what's actually needed (defense in depth) is preferable to keeping the full Admin Console reachable and fighting the gate's header behavior indefinitely.
- `kubectl port-forward` access to `hecate-service:8080` was already empirically verified to work cleanly (plain `200`, no auth-header interference), since it bypasses the public ingress/`oauth2-proxy` chain entirely.

## Considered Options

### Option A: Build a header-relay sidecar ("Iris") to preserve `Authorization` across the mandatory gate
Technically sound (an Nginx-based relay using `forwardAuth` middlewares before/after the gate to rename and restore the header), but adds a new container, two new Middleware resources, and ongoing operational surface for a feature (Admin Console) with an existing workaround.

### Option B: Scope the public `IngressRoute` to exclude `/admin/*` entirely (chosen)
No new infrastructure. Removes the conflict instead of working around it, since Keycloak's Admin REST API is simply never reached through the gate. Cerberus's login flow is unaffected since `/realms/*` and `/resources/*` stay public. Admin access moves to `kubectl port-forward`, already verified to work.

### Option C: Leave Hecate's entire ingress as-is (status quo, strip-both-ways)
Rejected per ADR-0015's amendment - still 401s on Admin Console REST calls after login, so doesn't actually fix the original problem.

## Decision Rationale

Option B eliminates the conflict with zero new infrastructure and no impact on Cerberus's login flow, which is the only genuinely public-browser-facing dependency Hecate has. The Admin Console was the sole reason for `hecate-strip-authorization`'s existence; once it's no longer publicly reachable, that middleware becomes unnecessary and is removed rather than kept as dead weight.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| No more conflict between Keycloak's Admin REST API and the cluster's mandatory oauth2-proxy gate; simpler chart (one fewer hand-authored Middleware) | Admin Console is no longer reachable from a browser without `kubectl` access to the cluster - acceptable since admin tasks are infrequent and operator-only, unlike end-user login |

## Consequences

### Positive
- `Hades/aspire-output/templates/hecate/middleware.yaml` is deleted; `hecate-ingress`'s `middlewares` list reverts to just whatever the deployer configured via `ingress-middleware-hecate` (normally the oauth2-proxy gate alone).
- Hecate's public attack surface shrinks to exactly the OIDC frontchannel paths Cerberus's login depends on.
- Cerberus's login/logout flow is unaffected - confirmed unchanged by this ADR, since `/realms/*` stays public and `KC_HOSTNAME`/`KC_HOSTNAME_BACKCHANNEL_DYNAMIC` (ADR-0011/ADR-0014) are untouched.

### Negative
- Admin tasks require `kubectl` cluster access (`kubectl port-forward svc/hecate-service 8080:8080 -n <namespace>`); not usable by someone without cluster credentials. Acceptable since admin tasks were always operator-only.

### Neutral
- Cerberus's and the dashboard's `IngressRoute`s are untouched; this ADR is scoped to Hecate only.

## Related Decisions

- [ADR-0011](./0011-front-hecate-cerberus-and-the-dashboard-with-traefik-ingressroutes.md) — establishes the hand-authored `IngressRoute` convention this ADR narrows for Hecate specifically.
- [ADR-0014](./0014-dynamic-backchannel-hostname-for-hecate.md) — the backchannel hostname fix this ADR's path-scoping is compatible with (backchannel calls stay internal, unaffected by the public route's `PathPrefix` scoping).
- [ADR-0015](./0015-strip-injected-authorization-header-for-hecate.md) — the abandoned header-stripping approach this ADR supersedes.

## Amendment (2026-10-23): hosts-file mapping required for port-forward access

Browsing straight to `http://localhost:<port>/admin/master/console/` after `kubectl port-forward` hits a different failure: the Admin Console hangs with **"somethingWentWrong - Timeout when waiting for 3rd party check iframe message."**

Cause: `KC_HOSTNAME` is fixed to the public hostname (`https://hecate.<host>`, per ADR-0011), so the Admin Console's own `keycloak.js` bootstrap always builds its silent third-party-cookie-check iframe (`/realms/master/.../3p-cookies/step1.html`) against *that* hostname, regardless of which URL the browser actually used to load the page. When the parent page is `localhost` and the iframe is the public hostname, this is a genuinely cross-origin, third-party-cookie-reliant iframe - modern browsers (Chrome, Firefox, Safari) block third-party cookie access by default, so the iframe never completes its handshake and the check times out.

**Fix**: map the public hostname to loopback locally, and browse through that hostname (not `localhost`) against the same port-forwarded port, so the browser considers the iframe same-site:

```powershell
# Run as Administrator (one-time):
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "127.0.0.1 hecate.<your-host>"
```

Then browse to `http://hecate.<your-host>:<port-forward-port>/admin/master/console/` instead of `http://localhost:<port>/...`. `KC_HOSTNAME_STRICT=false` (ADR-0010) means Keycloak itself doesn't enforce scheme/port matching, so plain HTTP on a non-standard port against the mapped hostname works correctly.

## Amendment (2026-10-23): HTTP vs HTTPS scheme mismatch also breaks the 3rd-party check

Even with the hosts-file mapping above, browsing `http://hecate.<host>:<port>/admin/master/console/` hit the **same** "Timeout when waiting for 3rd party check iframe message" error. Root cause: `KC_HOSTNAME` is `https://...`, so the Admin Console's 3rd-party-check iframe always loads over `https`, while the port-forwarded page itself is plain `http` (the pod serves HTTP internally per ADR-0010, TLS is normally terminated at the cluster ingress). Browsers' schemeful-same-site cookie rules treat `http://hecate.<host>` and `https://hecate.<host>` as different sites even on an identical hostname, so the iframe is still classified as third-party and blocked.

**Fix**: terminate TLS locally too, so both the parent page and its iframe are `https://` on the same hostname. A disposable local Caddy container does this with zero extra infrastructure beyond Docker, since `tls internal` auto-issues a self-signed cert for exactly the mapped hostname. See [`tools/hecate-admin-access/`](../../tools/hecate-admin-access/) for the committed, reusable Caddyfile and `docker run` command (the port used there was later corrected from an arbitrary one to 443 specifically - see the next amendment).

## Amendment (2026-10-23): a self-signed cert is blocked by HSTS click-through in Chromium browsers

Caddy's `tls internal` self-signed certificate triggers the standard browser "connection isn't private" warning - normally dismissible via "proceed anyway". However, if the exact hostname has previously set a (non-preloaded, dynamic) HSTS policy from a real visit through the public ingress, Chromium browsers (Edge, Chrome) **refuse to allow proceeding past a certificate error at all** while that policy is active, instead of just warning - "You can't visit ... right now because the website uses HSTS."

**Fix, if this happens**: clear the browser's cached HSTS policy for the hostname via `edge://net-internals/#hsts` / `chrome://net-internals/#hsts` ("Delete domain security policies"), then retry - the warning becomes click-through-able again. This was tried first with a locally-generated, trusted CA instead (avoiding the warning entirely), but that added real operational cost - a private key to generate and never commit, and a one-time *interactive* Windows trust-store import that cannot be scripted - for a problem (one click-through warning) that's one `net-internals` visit away from being a non-issue. Reverted to plain `tls internal`, now committed as [`tools/hecate-admin-access/`](../../tools/hecate-admin-access/) so the whole admin-access procedure is reproducible by any operator without regenerating anything by hand.

## Amendment (2026-10-23): the iframe still bypasses the local proxy unless it listens on the same (implicit default) port

The same "3rd party check iframe" timeout persisted even once the proxy was reachable. Root cause: `KC_HOSTNAME` has no explicit port, so `keycloak.js` always builds the 3rd-party-check iframe URL on the implicit default HTTPS port (443) - e.g. `https://hecate.<host>/realms/master/protocol/openid-connect/3p-cookies/step1.html` - regardless of what port the parent admin console page was actually loaded from. Browsing the admin console via some other local port (e.g. 8443) therefore made the iframe resolve to `https://hecate.<host>:443/...` - which, because of the hosts-file mapping to `127.0.0.1` added earlier for the admin-console workaround itself, now also resolves to `127.0.0.1:443`. Nothing was listening there, so the iframe's connection failed outright (confirmed via `curl`: connection refused), reproducing the identical timeout symptom.

**Fix**: run the local Caddy proxy on port **443** itself, matching `KC_HOSTNAME`'s implicit default port, so both the parent page and the iframe resolve to the exact same local origin. The committed [`tools/hecate-admin-access/Caddyfile`](../../tools/hecate-admin-access/Caddyfile) and its accompanying `README.md` reflect this final, working configuration: one hosts-file entry, one `docker run`, one click-through TLS warning, browse to `https://hecate.<your-host>/admin/master/console/` (no port in the URL). Windows does not restrict binding ports below 1024 to administrators the way Unix does, so no elevation is needed for the `docker run` itself.

Verified via `curl -k`: `/admin/master/console/`, `/realms/erebus/.well-known/openid-configuration`, and the exact 3p-cookies iframe path (`/realms/master/protocol/openid-connect/3p-cookies/step1.html`) all return a clean `200` on this single origin.

Note: the underlying `kubectl port-forward` to `hecate-service:8080` must stay alive for this whole chain to work - a dropped port-forward surfaces as a Caddy `502 dial tcp ...: connection refused`, not a TLS error; restart the port-forward if that appears.

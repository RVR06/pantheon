---
title: "Keycloak"
ring: "trial"
quadrant: "security-and-compliance"
tags: [iam, oidc]
---

Keycloak is an open-source identity and access management server implementing OpenID Connect and SAML, providing realms, clients, and user federation out of the box.

We picked it as the identity provider for the Tartarus spike (personified as Hecate, the realm as Erebus) because Aspire ships a first-class hosting integration for it, letting the whole IAM stack — realm import, admin console, token issuance — start alongside the rest of the spike with zero manual setup.

## Context

Tartarus needed an OIDC-compliant identity provider fronting a Blazor Web App and an ASP.NET Core API, with a realm auto-imported from a JSON file so the spike is runnable from a clean checkout without manual console clicking. No prior evaluation of alternatives (Auth0, Entra ID, Ory) was done for this spike specifically — Keycloak was chosen directly for its Aspire integration and self-hosted, license-free nature.

## Assessment

Keycloak has a long production track record industry-wide and a well-maintained Aspire hosting package (`Aspire.Hosting.Keycloak`) that wires realm import, data volumes, and container lifetime with a few lines of C#. For this spike, login, token validation in the API, and logout all worked end-to-end against a realm-imported configuration. The one friction point encountered was an `id_token_hint` validation error on logout redirect, a known class of issue with OIDC end-session endpoints and hostname/issuer mismatches, and worth tracking as a caveat for any deployment beyond localhost.

## Recommendation

The pattern sits in trial: the Aspire integration removes essentially all setup friction, and login/logout/token-validation flows work, but the logout hostname/issuer edge case observed here should be resolved and re-validated before recommending it as a default for anything beyond a spike.

## Next Steps

- Root-cause and fix the `id_token_hint` logout error before reusing this realm-import pattern in another spike
- Evaluate realm-export/version-control workflow if this pattern graduates beyond a single spike

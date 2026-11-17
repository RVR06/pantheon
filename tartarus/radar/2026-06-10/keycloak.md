---
title: "Keycloak"
ring: "assess"
quadrant: "security-and-compliance"
tags: [iam, oidc]
---

Keycloak is an open-source identity and access management server implementing OpenID Connect and SAML.

## Recommendation

Worth assessing as the identity provider for the Tartarus spike: the Aspire hosting integration promises a realm-import workflow with no manual setup, but nothing has been proven end-to-end yet, so it stays in assess until login, token validation and logout have been exercised.

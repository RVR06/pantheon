---
title: "JwtBearer"
ring: "adopt"
quadrant: "security-and-compliance"
tags: [auth, tokens]
---

Charon validates Hecate-issued tokens through JwtBearer; no custom validation code.

## Context

Tartarus uses JwtBearer as part of its stack; the ring below reflects what this team has seen in its own context.

## Assessment

Charon validates Hecate-issued tokens through JwtBearer; no custom validation code.

## Recommendation

Keep JwtBearer in adopt for Tartarus; revisit when the team's usage or the landscape stance changes.

## Next Steps

- Re-assess JwtBearer at the next radar review

---
title: "HttpClient"
ring: "adopt"
quadrant: "tools-and-patterns"
tags: [dotnet, http]
---

Typed clients with resilience handlers are the standard way Cerberus talks to Charon.

## Context

Tartarus uses HttpClient as part of its stack; the ring below reflects what this team has seen in its own context.

## Assessment

Typed clients with resilience handlers are the standard way Cerberus talks to Charon.

## Recommendation

Keep HttpClient in adopt for Tartarus; revisit when the team's usage or the landscape stance changes.

## Next Steps

- Re-assess HttpClient at the next radar review

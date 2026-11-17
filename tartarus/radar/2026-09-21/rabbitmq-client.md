---
title: "RabbitMQ.Client"
ring: "trial"
quadrant: "staples"
tags: [messaging, dotnet]
---

Version 7 ships its own OpenTelemetry spans, which is why Styx traffic stays traceable.

## Context

Tartarus uses RabbitMQ.Client as part of its stack; the ring below reflects what this team has seen in its own context.

## Assessment

Version 7 ships its own OpenTelemetry spans, which is why Styx traffic stays traceable.

## Recommendation

Keep RabbitMQ.Client in trial for Tartarus; revisit when the team's usage or the landscape stance changes.

## Next Steps

- Re-assess RabbitMQ.Client at the next radar review

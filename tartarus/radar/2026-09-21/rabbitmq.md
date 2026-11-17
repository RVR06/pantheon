---
title: "RabbitMQ"
ring: "trial"
quadrant: "platforms-and-operations"
tags: [messaging, o11y]
capability: "message broker"
---

A mature AMQP broker; Tartarus validated async tracing on it, durability and replay remain unproven.

## Context

Tartarus uses RabbitMQ as part of its stack; the ring below reflects what this team has seen in its own context.

## Assessment

A mature AMQP broker; Tartarus validated async tracing on it, durability and replay remain unproven.

## Recommendation

Keep RabbitMQ in trial for Tartarus; revisit when the team's usage or the landscape stance changes.

## Next Steps

- Re-assess RabbitMQ at the next radar review

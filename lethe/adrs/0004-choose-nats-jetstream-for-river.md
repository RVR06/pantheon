# 0004. Choose NATS JetStream for River

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-03-19

## Status

Accepted

## Decision Outcome

River, the internal message stream between Lethe API and Shredder, runs on NATS JetStream.

## Context

Lethe needs simple durable messaging with minimal operation; the realm already runs RabbitMQ and Kafka elsewhere.

## Decision Drivers

- Operational simplicity
- Durable streams
- Small footprint

## Considered Options

### Option A: RabbitMQ
Used by Tartarus, heavier for streams.

### Option B: NATS JetStream (chosen)
Light, durable, simple.

### Option C: Kafka
Overkill for this volume.

## Decision Rationale

JetStream fits the volume and keeps operation trivial, accepting a divergence from other realms.

## Consequences

Adds a third broker technology to the landscape; see the realm coupling ADRs.
